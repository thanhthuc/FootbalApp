//
//  Team.swift
//  FootballMatchesAndHighlight
//
//  Created by Nguyen Thanh Thuc on 15/01/2024.
//

import Foundation

public struct TeamContainerRoot: Codable {
  var teams: [Team]
  
  public init(teams: [Team]) {
    self.teams = teams
  }
  
  enum CodingKeys: String, CodingKey {
    case teams = "teams"
  }
}

public struct Team: Hashable, Codable {
  var id: String
  var name: String
  var logo: String
  var isSelected = false
  
  public init(id: String,
              name: String,
              logo: String,
              isSelected: Bool) {
    self.id = id
    self.name = name
    self.logo = logo
    self.isSelected = isSelected
  }
  
  enum CodingKeys: String, CodingKey {
    case id = "id"
    case name = "name"
    case logo = "logo"
  }
}
