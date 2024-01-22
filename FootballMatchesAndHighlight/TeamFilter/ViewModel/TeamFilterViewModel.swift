//
//  TeamFilterViewModel.swift
//  FootballMatchesAndHighlight
//
//  Created by Nguyen Thanh Thuc on 16/01/2024.
//

import Foundation
import Combine
import Network

protocol TeamFilterViewModelProtocol {
  var teamsPublisher: PassthroughSubject<[Team], Error> { get }
  var selectionTeams: [Team] { get set }
  func viewDidload()
}

class TeamFilterViewModel: TeamFilterViewModelProtocol {
  
  var teamsPublisher = PassthroughSubject<[Team], Error>()
  
  private let teamLocalRepository: LocalTeamRepository
  private let teamRemoteRepository: TeamRemoteRepository
  
  private var cancellables = Set<AnyCancellable>()
  
  private var _selectionTeams: [Team] = []
  var selectionTeams: [Team] {
    get {
      return _selectionTeams
    } set {
      _selectionTeams = newValue
      for team in _selectionTeams {
        let updateResult = teamLocalRepository.update(entity: team)
        switch updateResult {
          case .success:
            break
          case .failure(let error):
            teamsPublisher.send(completion: .failure(error))
        }
      }
    }
  }
  
  init(teamLocalRepository: LocalTeamRepository,
       teamRemoteRepository: TeamRemoteRepository) {
    self.teamLocalRepository = teamLocalRepository
    self.teamRemoteRepository = teamRemoteRepository
  }
  
  func viewDidload() {
    // Check offline first mode
    // local data first for fast loading
    let result = self.teamLocalRepository.getDataList(predicate: nil)
    switch result {
      case .success(let teams):
        teamsPublisher.send(teams)
      case .failure(let error):
        teamsPublisher.send(completion: .failure(error))
    }
  }
}

