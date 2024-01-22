//
//  TeamRepository.swift
//  FootballMatchesAndHighlight
//
//  Created by Nguyen Thanh Thuc on 13/01/2024.
//

import Foundation

import Foundation
import Combine

open class TeamRemoteRepository: RemoteRepositoryProtocol {
   
   private var apiClient: URLSessionAPIClient<TeamAPIEndpoint>
   private var cancallable = Set<AnyCancellable>()
   
   public init(apiClient: URLSessionAPIClient<TeamAPIEndpoint>) {
      self.apiClient = apiClient
   }
   
   open func fetchDataModel() -> AnyPublisher<TeamContainerRoot, Error> {
      return apiClient
         .sendRequest(endpoint: .getTeamDetail)
   }
}
