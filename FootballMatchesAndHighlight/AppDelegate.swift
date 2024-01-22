//
//  AppDelegate.swift
//  FootballMatchesAndHighlight
//
//  Created by Nguyen Thanh Thuc on 13/01/2024.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    window = UIWindow(frame: UIScreen.main.bounds)
    
    // MARK: - Inject service
    let matchesApiClient = URLSessionAPIClient<MatchesAPIEndpoint>()
    let matchesRemoteRepository = MatchesRemoteRepository(apiClient: matchesApiClient)
    let contextProvider = CoreDataContextProvider { error in
      debugPrint(String(describing: error))
    }
    
    // Matches local service
    let matchesCoreDataService = MatchesCoreDataService(managedObjectContext: contextProvider.backgroundContext)
    let matchesLocalRepository = LocalMatchesRepository(matchesCoreDataService: matchesCoreDataService)
    
    // Team remote service
    let teamApiClient = URLSessionAPIClient<TeamAPIEndpoint>()
    let teamRemoteRepository = TeamRemoteRepository(apiClient: teamApiClient)
    
    // Team local service
    let teamCoreDataService = TeamCoreDataService(managedObjectContext: contextProvider.backgroundContext)
    let teamLocalRepository = LocalTeamRepository(teamCoreDataService: teamCoreDataService)
    
    // Init view model
    let matchesListViewModel = MatchesListViewModel(
      matchesRemoteRepository: matchesRemoteRepository,
      matchesLocalRepository: matchesLocalRepository,
      teamRemoteRepository: teamRemoteRepository,
      teamLocalRepository: teamLocalRepository)
    let rootViewController = MatchesListViewController(matchesListViewModel: matchesListViewModel)
    
    let navigationController = UINavigationController(rootViewController: rootViewController)
    window?.rootViewController = navigationController
    window?.makeKeyAndVisible()
    
    // location core data
    let path = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
    print("\(path)")
    
    return true
  }
}

