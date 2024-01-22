//
//  TeamRepository.swift
//  FootballMatchesAndHighlight
//
//  Created by Nguyen Thanh Thuc on 21/01/2024.
//

import Foundation
import CoreData

open class LocalTeamRepository: LocalRepositoryProtocol {
  
  typealias Entity = Team
  
  private let teamCoreDataService: TeamCoreDataService
  public init(teamCoreDataService: TeamCoreDataService) {
    self.teamCoreDataService = teamCoreDataService
  }
  
  open func getDataList(predicate: NSPredicate?) -> Result<[Team], Error> {
    return teamCoreDataService.getList(predicate: predicate, sortDescriptors: nil)
  }
  
  open func getData(predicate: NSPredicate?) -> Result<Team, Error> {
    return teamCoreDataService.getFirst(predicate: predicate)
  }
  
  public func create(entity: Team) -> Result<Bool, Error> {
    return teamCoreDataService.create(entity: entity)
  }
  
  open func update(entity: Team) -> Result<Bool, Error> {
    let predicate = NSPredicate(format: "id == %@", entity.id)
    return teamCoreDataService.update(entity: entity, predicate: predicate)
  }
  
  public func createOrUpdate(entity: Team) -> Result<Bool, Error> {
    let predicate = NSPredicate(format: "id == %@", entity.id)
    return teamCoreDataService.createOrUpdate(entity: entity, predicate: predicate)
  }
  
  public func delete(entity: Team) -> Result<Bool, Error> {
    let predicate = NSPredicate(format: "id == %@", entity.id)
    return teamCoreDataService.delete(predicate: predicate)
  }
  
}
