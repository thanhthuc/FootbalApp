//
//  RemoteRepositoryProtocol.swift
//  FootballMatchesAndHighlight
//
//  Created by Nguyen Thanh Thuc on 15/01/2024.
//

import Foundation
import Combine

protocol RemoteRepositoryProtocol {
    associatedtype EntityType = Decodable
    func fetchDataModel() -> AnyPublisher<EntityType, Error>
}
