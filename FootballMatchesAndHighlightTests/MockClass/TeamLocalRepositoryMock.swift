//
//  TeamLocalRepositoryMock.swift
//  FootballMatchesAndHighlightTests
//
//  Created by Nguyen Thanh Thuc on 19/01/2024.
//

import Foundation
import FootballMatchesAndHighlight

class TeamLocalRepositoryMock: LocalTeamRepository {
  
  var isGetDataListSuccess = false
  
  override func getDataList(predicate: NSPredicate?) -> Result<[Team], Error> {
    
    if isGetDataListSuccess {
      let teams = [Team(id: "id", name: "name", logo: "logo.png", isSelected: false)]
      return .success(teams)
    } else {
      let error = NSError(domain: "domain", code: 0)
      return .failure(error)
    }
  }
  
  override func update(entity: Team) -> Result<Bool, Error> {
    if isGetDataListSuccess {
      return .success(true)
    } else {
      let error = NSError(domain: "domain", code: 0)
      return .failure(error)
    }
  }
}
