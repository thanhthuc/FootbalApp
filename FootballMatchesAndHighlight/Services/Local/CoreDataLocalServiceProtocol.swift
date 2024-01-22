//
//  CoreDataServiceProtocol.swift
//  FootballMatchesAndHighlight
//
//  Created by Nguyen Thanh Thuc on 21/01/2024.
//

import Foundation

enum CoreDataServiceError: Error {
  case invalidObjectType
  case notFound
  case saveChangeFailure
  
  var description: String {
    switch self {
      case .invalidObjectType:
        return "Invalid Object Type"
      case .notFound:
        return "Not found Object"
      case .saveChangeFailure:
        return "Can not save to database"
    }
  }
}

protocol CoreDataLocalServiceProtocol {
  associatedtype Entity
  func getList(predicate: NSPredicate?,
               sortDescriptors: [NSSortDescriptor]?) -> Result<[Entity], Error>
  func getFirst(predicate: NSPredicate?) -> Result<Entity, Error>
  func create(entity: Entity) -> Result<Bool, Error>
  func update(entity: Entity, predicate: NSPredicate?) -> Result<Bool, Error>
  func createOrUpdate(entity: Entity, predicate: NSPredicate?) -> Result<Bool, Error>
  func delete(predicate: NSPredicate?) -> Result<Bool, Error>
}
