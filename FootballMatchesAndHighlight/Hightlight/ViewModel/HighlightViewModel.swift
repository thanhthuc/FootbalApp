//
//  HighlightViewModel.swift
//  FootballMatchesAndHighlight
//
//  Created by Nguyen Thanh Thuc on 16/01/2024.
//

import Foundation
import Combine

protocol HighlightViewModelProtocol {
   var urlPublisher: PassthroughSubject<URL, Never> { get }
   func viewDidLoad()
}

struct HighlightViewModel: HighlightViewModelProtocol {
   
   var urlPublisher = PassthroughSubject<URL, Never>()
   
   private let url: URL
   
   init(url: URL) {
      self.url = url
   }
   
   func viewDidLoad() {
      urlPublisher.send(url)
   }
}
