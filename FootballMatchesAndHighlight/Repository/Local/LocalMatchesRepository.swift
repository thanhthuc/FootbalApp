//
//  MatchesLocalRepository.swift
//  FootballMatchesAndHighlight
//
//  Created by Nguyen Thanh Thuc on 21/01/2024.
//

import Foundation

class LocalMatchesRepository: LocalRepositoryProtocol {
  
  typealias Entity = Matches
  
  private let matchesCoreDataService: MatchesCoreDataService
  
  init(matchesCoreDataService: MatchesCoreDataService) {
    self.matchesCoreDataService = matchesCoreDataService
  }
  
  func getDataList(predicate: NSPredicate?) -> Result<[Matches], Error> {
    return matchesCoreDataService.getList(predicate: predicate, sortDescriptors: nil)
  }
  
  func getData(predicate: NSPredicate?) -> Result<Matches, Error> {
    return matchesCoreDataService.getFirst(predicate: predicate)
  }
  
  func create(entity: Matches) -> Result<Bool, Error> {
    return matchesCoreDataService.create(entity: entity)
  }
  
  func update(entity: Matches) -> Result<Bool, Error> {
    let predicate = NSPredicate(format: "matchDescription == %@", entity.description ?? "")
    return matchesCoreDataService.update(entity: entity, predicate: predicate)
  }
  
  func createOrUpdate(entity: Matches) -> Result<Bool, Error> {
    let predicate = NSPredicate(format: "matchDescription == %@", entity.description ?? "")
    return matchesCoreDataService.createOrUpdate(entity: entity, predicate: predicate)
  }
  
  func delete(entity: Matches) -> Result<Bool, Error> {
    let predicate = NSPredicate(format: "matchDescription == %@", entity.description ?? "")
    return matchesCoreDataService.delete(predicate: predicate)
  }
}
