//
//  TeamFilterViewModelTests.swift
//  FootballMatchesAndHighlightTests
//
//  Created by Nguyen Thanh Thuc on 18/01/2024.
//

import XCTest
@testable import FootballMatchesAndHighlight
import CoreData
import Combine

final class TeamFilterViewModelTests: XCTestCase {
  
  // Test system under test
  var sut: TeamFilterViewModel!
  var teamRemoteRepositoryMock: TeamRemoteRepositoryMock!
  var teamLocalRepositoryMock: TeamLocalRepositoryMock!
  var cancellables: Set<AnyCancellable>!
  
  override func setUpWithError() throws {
    // Init mock object
    let contextProvider = CoreDataContextProvider { error in }
    let dummyURLSessionTeamClient = URLSessionAPIClient<TeamAPIEndpoint>()
    teamRemoteRepositoryMock = TeamRemoteRepositoryMock(apiClient: dummyURLSessionTeamClient)
    
    let teamCoreDataService = TeamCoreDataService(managedObjectContext: contextProvider.backgroundContext)
    teamLocalRepositoryMock = TeamLocalRepositoryMock(teamCoreDataService: teamCoreDataService)
    cancellables = Set<AnyCancellable>()
    
    // Init system under test
    sut = TeamFilterViewModel(
      teamLocalRepository: teamLocalRepositoryMock,
      teamRemoteRepository: teamRemoteRepositoryMock
    )
  }
  
  override func tearDownWithError() throws {
    // Reset system under test
    sut = nil
    teamRemoteRepositoryMock = nil
    teamLocalRepositoryMock = nil
  }
  
  func testGetSelectionTeamsSuccess() {
    // Given
    let team = Team(id: "1", name: "Dragon", logo: "https://logo.png", isSelected: false)
    
    // When
    sut.selectionTeams = [team]
    
    // Then
    XCTAssertEqual(sut.selectionTeams.count, 1)
    XCTAssertEqual(sut.selectionTeams.first?.id, "1")
    XCTAssertEqual(sut.selectionTeams.first?.name, "Dragon")
    XCTAssertEqual(sut.selectionTeams.first?.logo, "https://logo.png")
    XCTAssertEqual(sut.selectionTeams.first?.isSelected, false)
  }
  
  func testSaveSelectionTeamsToLocalFailure() {
    // Given
    let team = Team(id: "1", name: "Dragon", logo: "https://logo.png", isSelected: false)
    teamLocalRepositoryMock.isGetDataListSuccess = false
    
    let expectation = self.expectation(description: "Local result")
    var errorResult: Error?
    var teamsResult: [Team] = []
    sut.teamsPublisher.sink { completionError in
      switch completionError{
        case .finished:
          break
        case .failure(let error):
          errorResult = error
      }
      expectation.fulfill()
    } receiveValue: { teams in
      teamsResult = teams
      expectation.fulfill()
    }
    .store(in: &cancellables)
    
    // When
    sut.selectionTeams = [team]
    
    wait(for: [expectation], timeout: 1)
    
    // Then
    XCTAssertNotNil(errorResult)
    XCTAssertEqual(teamsResult.count, 0)
  }
  
  func testViewDidloadGetTeamOfflineSuccess() {
    // Given
    teamLocalRepositoryMock.isGetDataListSuccess = true
    
    let expectation = self.expectation(description: "GetLocalTeamExpect")
    var teams: [Team] = []
    sut.teamsPublisher
      .sink(receiveCompletion: { error in
        expectation.fulfill()
      }, receiveValue: { teamsResult in
        teams = teamsResult
        expectation.fulfill()
      }).store(in: &cancellables)
    
    // When viewDidload
    sut.viewDidload()
    
    wait(for: [expectation], timeout: 0.5)
    
    // Then, return data success
    XCTAssertNotEqual(teams.count, 0)
  }
  
  func testViewDidloadGetTeamOfflineFailure() {
    // Given
    teamLocalRepositoryMock.isGetDataListSuccess = false
    
    let expectation = self.expectation(description: "GetRemoteTeamExpect")
    var teams: [Team] = []
    sut.teamsPublisher.sink(receiveCompletion: { error in
      expectation.fulfill()
    }, receiveValue: { teamsResult in
      teams = teamsResult
      expectation.fulfill()
    }).store(in: &cancellables)
    
    // When viewDidload
    sut.viewDidload()
    wait(for: [expectation], timeout: 0.5)
    
    // Then, team should equal 0
    XCTAssertEqual(teams.count, 0)
  }
}
