//
//  TeamRemoteRepositoryMock.swift
//  FootballMatchesAndHighlightTests
//
//  Created by Nguyen Thanh Thuc on 19/01/2024.
//

import Foundation
import FootballMatchesAndHighlight
import Combine

class TeamRemoteRepositoryMock: TeamRemoteRepository {
  var isGetRemoteDataListSuccess = true
  var teamsPublisher = PassthroughSubject<TeamContainerRoot, Error>()
  override func fetchDataModel() -> AnyPublisher<TeamContainerRoot, Error> {
    if isGetRemoteDataListSuccess {
      let team = Team(id: "id", name: "name", logo: "logo.png", isSelected: false)
      let teamContainerRoot = TeamContainerRoot(teams: [team])
      let currentValue = CurrentValueSubject<TeamContainerRoot, Error>(teamContainerRoot)
      return currentValue.eraseToAnyPublisher()
    } else {
      return Empty().eraseToAnyPublisher()
    }
    
  }
}
