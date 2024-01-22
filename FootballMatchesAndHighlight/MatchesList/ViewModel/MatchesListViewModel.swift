//
//  MatchesListViewModel.swift
//  FootballMatchesAndHighlight
//
//  Created by Nguyen Thanh Thuc on 16/01/2024.
//

import Foundation
import Combine

protocol MatchesListViewModelProtocol {
  var matchesListPublisher: PassthroughSubject<(upcoming: [Matches],
                                                previous: [Matches]), Error> { get }
  var teamsListPublisher: PassthroughSubject<[Team], Error> { get }
  var isUpcoming: Bool { get set }
  func viewDidLoad()
  func getTeamLocalRespository() -> LocalTeamRepository
  func getTeamRemoteRespository() -> TeamRemoteRepository
}

class MatchesListViewModel: MatchesListViewModelProtocol {
  var matchesListPublisher = PassthroughSubject<(upcoming: [Matches],
                                                 previous: [Matches]), Error>()
  var teamsListPublisher = PassthroughSubject<[Team], Error>()
  private var cancellables = Set<AnyCancellable>()
  private let matchesRemoteRepository: MatchesRemoteRepository
  private let matchesLocalRepository: LocalMatchesRepository
  private let teamRemoteRepository: TeamRemoteRepository
  private let teamLocalRepository: LocalTeamRepository
  
  private var _isUpcomming: Bool = false
  var isUpcoming: Bool {
    get {
      return _isUpcomming
    }
    set {
      _isUpcomming = newValue
    }
  }
  
  init(matchesRemoteRepository: MatchesRemoteRepository,
       matchesLocalRepository: LocalMatchesRepository,
       teamRemoteRepository: TeamRemoteRepository,
       teamLocalRepository: LocalTeamRepository) {
    self.matchesRemoteRepository = matchesRemoteRepository
    self.matchesLocalRepository = matchesLocalRepository
    self.teamRemoteRepository = teamRemoteRepository
    self.teamLocalRepository = teamLocalRepository
  }
  
  func viewDidLoad() {
    loadLocalData()
    setupTeamsAPIPublisher()
    setupMatchesAPIPublisher()
  }
  
  private func loadLocalData() {
    // Trigger offline data first for quickly loading
    let matchesListResult = matchesLocalRepository.getDataList(predicate: nil)
    switch matchesListResult {
      case .success(let matchesList):
        let upcoming = matchesList.filter { $0.highlights == nil }
        let previous = matchesList.filter { $0.highlights != nil }
        matchesListPublisher.send(
          (upcoming: upcoming, previous: previous)
        )
      case .failure(let error):
        matchesListPublisher.send(completion: .failure(error))
    }
    
    let teamListResult = teamLocalRepository.getDataList(predicate: nil)
    switch teamListResult {
      case .success(let teams):
        teamsListPublisher.send(teams)
      case .failure(let error):
        teamsListPublisher.send(completion: .failure(error))
    }
  }
  
  private func setupTeamsAPIPublisher() {
    self.teamRemoteRepository.fetchDataModel().sink { [weak self] (completionError) in
      guard let self else { return }
      switch completionError {
        case .finished:
          debugPrint("Error")
        case .failure(let error):
          self.teamsListPublisher.send(completion: .failure(error))
      }
      // 5. Design API best practice and convention, add REAME, Add new video demo, check access control, check the way to call api use combine reactive
      
      // TODO
      // Pull to refresh and paging if needed
    } receiveValue: { [weak self] teamContainer in
      
      guard let self else { return }
      self.teamsListPublisher.send(teamContainer.teams)
      
      // Then save to database if needed
      for var team in teamContainer.teams {
        // Keep old selected item
        let predicate = NSPredicate(format: "id == %@", team.id)
        let teamLocalResult = teamLocalRepository.getData(predicate: predicate)
        switch teamLocalResult {
          case .success(let localTeam):
            team.isSelected = localTeam.isSelected
          case .failure(let error):
            debugPrint(error.localizedDescription)
            teamsListPublisher.send(completion: .failure(error))
        }
        let updateCreateResult = self.teamLocalRepository.createOrUpdate(entity: team)
        switch updateCreateResult {
          case .success:
            break
          case .failure(let error):
            teamsListPublisher.send(completion: .failure(error))
        }
      }
    }.store(in: &cancellables)
  }
  
  private func setupMatchesAPIPublisher() {
    matchesRemoteRepository.fetchDataModel().sink { [weak self] (errorCompletion) in
      guard let self else { return }
      switch errorCompletion {
        case .finished:
          debugPrint("Fnished: \(#function)")
        case .failure(let error):
          self.matchesListPublisher.send(completion: .failure(error))
      }
    } receiveValue: { [weak self] matchesContainer in
      guard let self else { return }
      let upcoming = matchesContainer.matches.upcoming
      let previous = matchesContainer.matches.previous
      self.matchesListPublisher.send((upcoming: upcoming, previous: previous))
      
      // Then save to database if needed
      for matches in upcoming {
        let createOrUpdateResult = self.matchesLocalRepository.createOrUpdate(entity: matches)
        switch createOrUpdateResult {
          case .success(_):
            break
          case .failure(let error):
            self.matchesListPublisher.send(completion: .failure(error))
        }
      }
      
      for matches in previous {
        let createOrUpdateResult = self.matchesLocalRepository.createOrUpdate(entity: matches)
        switch createOrUpdateResult {
          case .success:
            break
          case .failure(let error):
            matchesListPublisher.send(completion: .failure(error))
        }
      }
      
    }.store(in: &cancellables)
  }
  
  func getTeamLocalRespository() -> LocalTeamRepository {
    return self.teamLocalRepository
  }
  
  func getTeamRemoteRespository() -> TeamRemoteRepository {
    return self.teamRemoteRepository
  }
}
