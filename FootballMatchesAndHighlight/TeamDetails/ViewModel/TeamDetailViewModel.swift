//
//  TeamDetailViewModel.swift
//  FootballMatchesAndHighlight
//
//  Created by Nguyen Thanh Thuc on 16/01/2024.
//

import Foundation
import Combine

protocol TeamDetailViewModelProtocol {
    var teamPublisher: PassthroughSubject<(team: Team, allMatches: [Matches], teamsToFetch: [Team]), Never> { get }
    func viewDidload()
}

class TeamDetailViewModel: TeamDetailViewModelProtocol {
    
    var teamPublisher = PassthroughSubject<(team: Team, allMatches: [Matches], teamsToFetch: [Team]), Never>()
    
    private let team: Team
    private let allMatches: [Matches]
    private let teamsToFetch: [Team]
    init(team: Team,
         allMatches: [Matches],
         teamsToFetch: [Team]) {
        self.team = team
        self.allMatches = allMatches
        self.teamsToFetch = teamsToFetch
    }
    
    func viewDidload() {
        teamPublisher.send((team: team, allMatches: allMatches, teamsToFetch: teamsToFetch))
    }
}
