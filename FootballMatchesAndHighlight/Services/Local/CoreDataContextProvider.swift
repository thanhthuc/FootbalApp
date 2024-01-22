//
//  CoreDataContextProvider.swift
//  FootballMatchesAndHighlight
//
//  Created by Nguyen Thanh Thuc on 17/01/2024.
//

import Foundation
import CoreData

class CoreDataContextProvider {
  
  private var persistentContainer: NSPersistentContainer
  
  init(completion: @escaping (Error?) -> Void) {
    
    self.persistentContainer = NSPersistentContainer(name: "FootballMatchesAndHighlight")
    persistentContainer.loadPersistentStores { description, error in
      if let error {
        completion(error)
      } else {
        completion(nil)
      }
    }
  }
  // main thread context
  var viewContext: NSManagedObjectContext {
    return persistentContainer.viewContext
  }
  
  // background thread context
  var backgroundContext: NSManagedObjectContext {
    return persistentContainer.newBackgroundContext()
  }
  
}
