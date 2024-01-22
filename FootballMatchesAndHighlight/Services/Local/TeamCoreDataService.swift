//
//  TeamCoreDataService.swift
//  FootballMatchesAndHighlight
//
//  Created by Nguyen Thanh Thuc on 21/01/2024.
//

import Foundation
import CoreData

public class TeamCoreDataService: CoreDataLocalServiceProtocol {
  
  typealias Entity = Team
  
  private let managedObjectContext: NSManagedObjectContext
  init(managedObjectContext: NSManagedObjectContext) {
    self.managedObjectContext = managedObjectContext
  }
  
  func getList(predicate: NSPredicate?,
               sortDescriptors: [NSSortDescriptor]?) -> Result<[Team], Error> {
    let fetchRequest = TeamMO.fetchRequest()
    fetchRequest.predicate = predicate
    fetchRequest.sortDescriptors = sortDescriptors
    do {
      let fetchResult = try managedObjectContext.fetch(fetchRequest)
      let teamList = fetchResult.map { $0.toDomainModel() }
      return .success(teamList)
    } catch {
      return .failure(error)
    }
  }
  
  func getFirst(predicate: NSPredicate?) -> Result<Team, Error> {
    let fetchRequest = TeamMO.fetchRequest()
    fetchRequest.predicate = predicate
    do {
      if let fetchResult = try managedObjectContext.fetch(fetchRequest).first {
        let team = fetchResult.toDomainModel()
        return .success(team)
      }
      return .failure(CoreDataServiceError.notFound)
    } catch {
      return .failure(error)
    }
  }
  
  func create(entity: Team) -> Result<Bool, Error> {
    let teamMO = TeamMO(context: managedObjectContext)
    teamMO.id = entity.id
    teamMO.name = entity.name
    teamMO.logo = entity.logo
    teamMO.isSelectedFilter = entity.isSelected
    return saveChange()
  }
  
  func update(entity: Team, predicate: NSPredicate?) -> Result<Bool, Error> {
    let fetchRequest = TeamMO.fetchRequest()
    fetchRequest.predicate = predicate
    do {
      if let teamMO = try managedObjectContext.fetch(fetchRequest).first {
        teamMO.id = entity.id
        teamMO.name = entity.name
        teamMO.logo = entity.logo
        teamMO.isSelectedFilter = entity.isSelected
        return saveChange()
      }
      return .failure(CoreDataServiceError.notFound)
    } catch {
      return .failure(error)
    }
  }
  
  func createOrUpdate(entity: Team, predicate: NSPredicate?) -> Result<Bool, Error> {
    // Check if object is existed, do not create again
    let fetchRequest = TeamMO.fetchRequest()
    fetchRequest.predicate = predicate
    do {
      let count = try managedObjectContext.count(for: fetchRequest)
      if count > 0 {
        // Exist, just update
        return update(entity: entity, predicate: predicate)
      } else {
        // Not exist, create
        return create(entity: entity)
      }
    } catch {
      return .failure(error)
    }
  }
  
  func delete(predicate: NSPredicate?) -> Result<Bool, Error> {
    let fetchRequest = TeamMO.fetchRequest()
    fetchRequest.predicate = predicate
    do {
      if let teamMO = try managedObjectContext.fetch(fetchRequest).first {
        managedObjectContext.delete(teamMO)
        return saveChange()
      }
      return .failure(CoreDataServiceError.notFound)
    } catch {
      return .failure(error)
    }
  }
  
  private func saveChange() -> Result<Bool, Error> {
    if managedObjectContext.hasChanges {
      do {
        try managedObjectContext.save()
        return .success(true)
      } catch {
        return .failure(error)
      }
    }
    return .failure(CoreDataServiceError.saveChangeFailure)
  }
}
