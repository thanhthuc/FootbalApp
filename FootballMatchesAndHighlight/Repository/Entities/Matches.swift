//
//  Matches.swift
//  FootballMatchesAndHighlight
//
//  Created by Nguyen Thanh Thuc on 15/01/2024.
//

import Foundation

public struct MatchesContainerRoot: Codable {
    var matches: MatchesContainer
    enum CodingKeys: String, CodingKey {
        case matches = "matches"
    }
}

public struct MatchesContainer: Codable {
    var previous: [Matches]
    var upcoming: [Matches]
    
    enum CodingKeys: String, CodingKey {
        case previous = "previous"
        case upcoming = "upcoming"
    }
}

public struct Matches: Hashable, Codable {
    var date: String?
    var description: String?
    var home: String?
    var away: String?
    var winner: String?
    var highlights: String?
    
    enum CodingKeys: String, CodingKey  {
        case date = "date"
        case description = "description"
        case home = "home"
        case away = "away"
        case winner = "winner"
        case highlights = "highlights"
    }
}
