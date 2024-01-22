//
//  RepositoryProtocol.swift
//  FootballMatchesAndHighlight
//
//  Created by Nguyen Thanh Thuc on 21/01/2024.
//

import Foundation

/// Top level local repository
protocol LocalRepositoryProtocol {
  associatedtype Entity
  func getDataList(predicate: NSPredicate?) -> Result<[Entity], Error>
  func getData(predicate: NSPredicate?) -> Result<Entity, Error>
  func create(entity: Entity) -> Result<Bool, Error>
  func update(entity: Entity) -> Result<Bool, Error>
  func delete(entity: Entity) -> Result<Bool, Error>
  func createOrUpdate(entity: Entity) -> Result<Bool, Error>
}

enum RepositoryError: Error {
  case existedObject
  
  var description: String {
    switch self {
      case .existedObject:
        return "Existed object, please check again"
    }
  }
}

protocol DomainModelProtocol {
  associatedtype DomainModelType
  func toDomainModel() -> DomainModelType
}
