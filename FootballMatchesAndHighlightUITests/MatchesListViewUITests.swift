//
//  MatchesListViewUITests.swift
//  FootballMatchesAndHighlightUITests
//
//  Created by Nguyen Thanh Thuc on 18/01/2024.
//

import XCTest

final class MatchesListViewUITests: XCTestCase {
  
  var app: XCUIApplication!
  
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    continueAfterFailure = false
    
    app = XCUIApplication()
    // Setup argument of needed
    // app.launchArguments = ["testing"]
    app.launch()
  }
  
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testFilterButtonExisted() {
    XCTAssertTrue(app.buttons["filterButton"].exists)
  }
  
  func testFilterSegmentExist() {
    XCTAssertTrue(app.segmentedControls["matchesSegmentControlID"].exists)
  }
  
  func testTapFilterButton() {
    // When
    app.buttons["filterButton"].tap()
    // Then
    XCTAssertTrue(app.buttons["DoneButton"].exists)
  }
  
  func testHighlightButtonExist() {
    XCTAssertTrue(app.buttons["highlightButtonID\(1)"].exists)
  }
}
