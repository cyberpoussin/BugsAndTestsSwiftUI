//
//  APIPalett.swift
//  NewFlowerApp
//
//  Created by Admin on 11/02/2021.
//

import SwiftUI
import Combine


enum NetworkRequestError: LocalizedError, Equatable {
    case invalidRequest
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case error4xx(_ code: Int)
    case serverError
    case error5xx(_ code: Int)
    case decodingError
    case urlSessionFailed(_ error: URLError)
    case unknownError
}



protocol APIManager {
    var session: URLSession { get }
    func request<Endpoint: RequestBuilder>(with: Endpoint) -> AnyPublisher<Endpoint.ResponseType?, Never>
    func request<Endpoint: RequestBuilder>(with: Endpoint) -> AnyPublisher<Data?, Never>

}


// https://api.upcitemdb.com/prod/trial/lookup?upc=7045950671798

enum Endpoint<T: Decodable>: RequestBuilder {
    typealias ResponseType = T
    
    case fetchItem(upc: String)

    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.upcitemdb.com"
        components.path = "/prod/trial"
        //let queryItems = [URLQueryItem(name: "api_key", value: "keyXSumLVSJRFmMRd")]
        
        switch self {
        case let .fetchItem(upc):
            components.path += "/lookup"
            components.queryItems = [URLQueryItem(name: "upc", value: upc)]
            return components.url
        }
    }
}

protocol RequestBuilder {
    associatedtype ResponseType: Decodable
    var url: URL? {get}
}

extension APIManager {
    private func httpError(_ statusCode: Int) -> NetworkRequestError {
            switch statusCode {
            case 400: return .badRequest
            case 401: return .unauthorized
            case 403: return .forbidden
            case 404: return .notFound
            case 402, 405...499: return .error4xx(statusCode)
            case 500: return .serverError
            case 501...599: return .error5xx(statusCode)
            default: return .unknownError
            }
        }
        /// Parses URLSession Publisher errors and return proper ones
        /// - Parameter error: URLSession publisher error
        /// - Returns: Readable NetworkRequestError
    func handleError(_ error: Error) -> NetworkRequestError {
            switch error {
            case is Swift.DecodingError:
                return .decodingError
            case let urlError as URLError:
                return .urlSessionFailed(urlError)
            case let error as NetworkRequestError:
                return error
            default:
                return .unknownError
            }
        }
}

extension APIManager {
    
    func dataTask<Endpoint: RequestBuilder>(request: Endpoint) -> AnyPublisher<Endpoint.ResponseType, NetworkRequestError>{
        guard let request = request.url else { return Fail(error: NetworkRequestError.invalidRequest).eraseToAnyPublisher() }
        return session.dataTaskPublisher(for: request)
            .tryMap {(data, response) -> Data in
                guard let response = response as? HTTPURLResponse else {
                    throw NetworkRequestError.unknownError
                }
                switch response.statusCode {
                case 200...299: return data
                default: throw httpError(response.statusCode)
                }
            }
            .decode(type: Endpoint.ResponseType.self, decoder: JSONDecoder())
            .mapError {
                handleError($0)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    
    
    func request<Endpoint: RequestBuilder>(with requestBuilder: Endpoint) -> AnyPublisher<Endpoint.ResponseType?, Never> {
        guard let request = requestBuilder.url else { return Just(nil).eraseToAnyPublisher() }
        return session.dataTaskPublisher(for: request)
            .map { response -> Data in
                print(String(data: response.data, encoding: .utf8)!)
                return response.data
            }
            .decode(type: Endpoint.ResponseType?.self, decoder: JSONDecoder())
            .catch { error -> AnyPublisher<Endpoint.ResponseType?, Never> in
                print(error)
                return Just(nil).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func request<Endpoint: RequestBuilder>(with requestBuilder: Endpoint) -> AnyPublisher<Data?, Never> {
        guard let request = requestBuilder.url else { return Just(nil).eraseToAnyPublisher() }
        return session.dataTaskPublisher(for: request)
            .map { response -> Data in
                print(String(data: response.data, encoding: .utf8)!)
                return response.data
            }
            .catch { error -> AnyPublisher<Data?, Never> in
                print(error)
                return Just(nil).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

class APISession: APIManager {
    var session: URLSession = URLSession.shared
}

