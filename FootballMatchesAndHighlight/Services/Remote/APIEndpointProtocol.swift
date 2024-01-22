//
//  APIEndpointProtocol.swift
//  FootballMatchesAndHighlight
//
//  Created by Nguyen Thanh Thuc on 13/01/2024.
//

import Foundation

public enum HTTPMethod: String {
   case get = "GET"
   case post = "POST"
   case put = "PUT"
   case patch = "PATCH"
   case delete = "DELETE"
}

public protocol APIEndpointProtocol {
   var baseURL: URL { get }
   var path: String { get }
   var method: HTTPMethod { get }
   var headers: [String: String]? { get }
   var parameters: [String: Any]? { get }
}

/// Default implementation
public extension APIEndpointProtocol {
   
   var headers: [String: String]? {
      return nil
   }
   
   var parameters: [String: Any]? {
      return nil
   }
}
