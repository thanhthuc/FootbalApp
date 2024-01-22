//
//  CoreDataLocalService.swift
//  FootballMatchesAndHighlight
//
//  Created by Nguyen Thanh Thuc on 21/01/2024.
//

import Foundation
import CoreData

class MatchesCoreDataService: CoreDataLocalServiceProtocol {
  
  typealias Entity = Matches
  
  private let managedObjectContext: NSManagedObjectContext
  
  init(managedObjectContext: NSManagedObjectContext) {
    self.managedObjectContext = managedObjectContext
  }
  
  func getList(predicate: NSPredicate?,
               sortDescriptors: [NSSortDescriptor]?) -> Result<[Matches], Error> {
    let fetchRequest = MatchesMO.fetchRequest()
    fetchRequest.predicate = predicate
    fetchRequest.sortDescriptors = sortDescriptors
    do {
      let fetchResults = try managedObjectContext.fetch(fetchRequest)
      let matchesList = fetchResults.map { $0.toDomainModel() }
      return .success(matchesList)
    } catch {
      return .failure(error)
    }
  }
  
  func getFirst(predicate: NSPredicate?) -> Result<Matches, Error> {
    let fetchRequest = MatchesMO.fetchRequest()
    fetchRequest.predicate = predicate
    do {
      let fetchResults = try managedObjectContext.fetch(fetchRequest)
      if let firstObject = fetchResults.first {
        return .success(firstObject.toDomainModel())
      }
      return .failure(CoreDataServiceError.notFound)
    } catch {
      return .failure(error)
    }
  }
  
  func create(entity: Matches) -> Result<Bool, Error> {
    
    let matchesMO = MatchesMO(context: managedObjectContext)
    matchesMO.date = entity.date
    matchesMO.matchDescription = entity.description
    matchesMO.home = entity.home
    matchesMO.away = entity.away
    matchesMO.winner = entity.winner
    matchesMO.highlights = entity.highlights
    return saveChange()
  }
  
  func update(entity: Matches, predicate: NSPredicate?) -> Result<Bool, Error> {
    let request = MatchesMO.fetchRequest()
    request.fetchLimit = 1
    request.predicate = predicate
    do {
      let matchesMO = try managedObjectContext.fetch(request).first
      matchesMO?.date = entity.date
      matchesMO?.matchDescription = entity.description
      matchesMO?.home = entity.home
      matchesMO?.away = entity.away
      matchesMO?.winner = entity.winner
      matchesMO?.highlights = entity.highlights
      
      return saveChange()
    } catch {
      return .failure(error)
    }
  }
  
  func createOrUpdate(entity: Matches, predicate: NSPredicate?) -> Result<Bool, Error> {
    let fetchRequest = MatchesMO.fetchRequest()
    fetchRequest.predicate = predicate
    do {
      let count = try managedObjectContext.count(for: fetchRequest)
      if count > 0 {
        // Exist, just update and sync
        return update(entity: entity, predicate: predicate)
      } else {
        // Not exist, just create
        return create(entity: entity)
      }
    } catch {
      return .failure(error)
    }
  }
  
  func delete(predicate: NSPredicate?) -> Result<Bool, Error> {
    let request = MatchesMO.fetchRequest()
    request.predicate = predicate
    request.fetchLimit = 1
    do {
      if let matchesMO = try managedObjectContext.fetch(request).first {
        managedObjectContext.delete(matchesMO)
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
