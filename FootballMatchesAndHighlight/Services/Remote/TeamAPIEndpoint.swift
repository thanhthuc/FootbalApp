//
//  APIClient.swift
//  FootballMatchesAndHighlight
//
//  Created by Nguyen Thanh Thuc on 13/01/2024.
//

import Foundation

public enum TeamAPIEndpoint: APIEndpointProtocol {
   public var baseURL: URL {
      return URL(string: "https://jmde6xvjr4.execute-api.us-east-1.amazonaws.com")!
   }
   
   public var path: String {
      switch self {
         case .getTeamDetail:
            return "/teams"
      }
   }
   
   public var method: HTTPMethod {
      switch self {
         case .getTeamDetail:
            return .get
      }
   }
   
   case getTeamDetail
   
}
