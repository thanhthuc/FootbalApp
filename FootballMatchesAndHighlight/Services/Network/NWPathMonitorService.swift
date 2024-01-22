//
//  NWPathMonitorService.swift
//  FootballMatchesAndHighlight
//
//  Created by Nguyen Thanh Thuc on 19/01/2024.
//

import Foundation
import Network
import Combine

public struct CustomNetworkPath {
   public var status: NWPath.Status
   
   public init(status: NWPath.Status) {
      self.status = status
   }
}

extension CustomNetworkPath {
   public init(rawValue: NWPath) {
      self.status = rawValue.status
   }
}

extension CustomNetworkPath: Equatable {}

public protocol NWPathCreationProtocol {
   var nwPathPublisher: AnyPublisher<CustomNetworkPath, Never>? { get }
   func start()
}

final class NWPathCreation: NWPathCreationProtocol {
   
   public var nwPathPublisher: AnyPublisher<CustomNetworkPath, Never>?
   private let subject = PassthroughSubject<NWPath, Never>()
   private let nwPathMonitor = NWPathMonitor()
   
   func start() {
      nwPathMonitor.pathUpdateHandler = subject.send
      nwPathPublisher = subject
         .handleEvents(
            receiveSubscription: { _ in self.nwPathMonitor.start(queue: .main) },
            receiveCancel: nwPathMonitor.cancel
         )
         .map(CustomNetworkPath.init(rawValue:))
         .eraseToAnyPublisher()
   }
}

// Wrapper
final class MyNWPathMonitor: ObservableObject {
    @Published var isConnected = true
    
    private var pathUpdateCancellable: AnyCancellable?
    let paths: NWPathCreationProtocol
    init(
        paths: NWPathCreationProtocol = NWPathCreation()
    ) {
        self.paths = paths
        paths.start()
        self.pathUpdateCancellable = paths.nwPathPublisher?
            .sink(receiveValue: { [weak self] isConnected in
                self?.isConnected = isConnected == CustomNetworkPath(status: .satisfied)
            })
    }
}
