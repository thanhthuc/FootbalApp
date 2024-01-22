//
//  MatchesRemoteRepository.swift
//  FootballMatchesAndHighlight
//
//  Created by Nguyen Thanh Thuc on 13/01/2024.
//

import Foundation
import Combine

open class MatchesRemoteRepository: RemoteRepositoryProtocol {
    
    private var apiClient: URLSessionAPIClient<MatchesAPIEndpoint>
    private var cancallable = Set<AnyCancellable>()
    
    public init(apiClient: URLSessionAPIClient<MatchesAPIEndpoint>) {
        self.apiClient = apiClient
    }
    
    open func fetchDataModel() -> AnyPublisher<MatchesContainerRoot, Error> {
        return apiClient
            .sendRequest(endpoint: .getMatches)
    }
}
