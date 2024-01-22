//
//  APIClientProtocol.swift
//  FootballMatchesAndHighlight
//
//  Created by Nguyen Thanh Thuc on 14/01/2024.
//

import Foundation
import Combine

enum URLSessionHTTPClientError: Error {
  case imformationResponse
  case redirectionMessageResponse
  case clientErrorResponse
  case serverErrorResponse
  case undefinedError
  case invalidReponse
  
  var description: String {
    switch self {
      case .imformationResponse:
        return "Imformation response error, please check again"
      case .redirectionMessageResponse:
        return "Redirection message response, please check again"
      case .clientErrorResponse:
        return "Client error response, please check again"
      case .serverErrorResponse:
        return "Server error response, please check again"
      case .undefinedError:
        return "Undefine from server, please check again"
      case .invalidReponse:
        return "Invalid response, please check again"
    }
  }
}

protocol APIClientProtocol {
  associatedtype EndpointType = APIEndpointProtocol
  func sendRequest<T: Decodable>(endpoint: EndpointType) -> AnyPublisher<T, Error>
}

public class URLSessionAPIClient<EndpointType: APIEndpointProtocol>: APIClientProtocol {
  
  func sendRequest<T: Decodable>(endpoint: EndpointType) -> AnyPublisher<T, Error> {
    
    let url = endpoint.baseURL.appendingPathComponent(endpoint.path)
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = endpoint.method.rawValue
    
    endpoint.headers?.forEach({ header in
      urlRequest.addValue(header.value, forHTTPHeaderField: header.key)
    })
    
    return URLSession
      .shared
      .dataTaskPublisher(for: urlRequest)
      .tryMap { (data: Data, response: URLResponse)  -> Data in
        
        guard let httpResponse = response as? HTTPURLResponse else {
          throw URLSessionHTTPClientError.invalidReponse
        }
        
        switch httpResponse.statusCode {
          case 100...199:
            throw URLSessionHTTPClientError.imformationResponse
          case 200...299:
            return data
          case 300...399:
            throw URLSessionHTTPClientError.redirectionMessageResponse
          case 400...499:
            throw URLSessionHTTPClientError.clientErrorResponse
          case 500...599:
            throw URLSessionHTTPClientError.serverErrorResponse
          default:
            throw URLSessionHTTPClientError.undefinedError
        }
      }
      .decode(type: T.self, decoder: JSONDecoder())
      .subscribe(on: DispatchQueue.global(qos: .background))
      .eraseToAnyPublisher()
    
  }
}
