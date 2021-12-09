//
//  NetworkService.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Combine
import Foundation

enum NetworkError: Error {
    case invalidURL
    case emptyResponse
    case noAuthToken
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

struct RequestData {
    let auth: Bool
    let path: String
    let method: HTTPMethod
    let params: Params?
    let headers: [String: String]?

    init(
        path: String,
        method: HTTPMethod = .get,
        auth: Bool = false,
        params: Params? = nil,
        headers: [String: String]? = nil
    ) {
        self.path = path
        self.method = method
        self.params = params
        self.auth = auth
        self.headers = headers
    }

    struct Params {
        fileprivate var data: Data?
        fileprivate var headers: [String: String]

        static func json<T: Encodable>(_ model: T) -> Params {
            Params(
                data: try? JSONEncoder().encode(model),
                headers: ["Content-Type": "application/json"]
            )
        }

        static func urlenencoded<T: Encodable>(_ model: T) -> Params {
            guard
                let data = Params.json(model).data,
                let dict = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [AnyHashable: AnyHashable]
            else {
                return Params(data: nil, headers: [:])
            }
            var component = URLComponents()
            var items: [URLQueryItem] = []
            dict.enumerated().forEach {
                if let name = $0.element.key as? String {
                    items.append(URLQueryItem(name: name, value: $0.element.value.description))
                }
            }
            component.queryItems = items
            return Params(
                data: component.query?.data(using: .utf8),
                headers: [:]
            )
        }
    }
}


protocol RequestType {
    associatedtype ResponseType: Decodable
    var data: RequestData { get }
}

extension RequestType {
    func execute (
        dispatcher: NetworkDispatcher = URLSessionNetworkDispatcher.instance
    ) -> AnyPublisher<ResponseType, Error> {
        dispatcher.dispatch(request: self.data)
            .tryMap { try JSONDecoder().decode(ResponseType.self, from: $0) }
            .eraseToAnyPublisher()
    }
}

protocol NetworkDispatcher {
    func dispatch(request: RequestData) -> AnyPublisher<Data, Error>
}

struct URLSessionNetworkDispatcher: NetworkDispatcher {
    static let instance = URLSessionNetworkDispatcher()
    private init() {}

    func dispatch(request: RequestData) -> AnyPublisher<Data, Error> {
        guard let url = URL(string: request.path) else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue

        request.params.flatMap { params in
            urlRequest.httpBody = params.data
            params.headers.forEach {
                urlRequest.setValue($0.value, forHTTPHeaderField: $0.key)
            }
        }

        request.headers
            .flatMap { urlRequest.allHTTPHeaderFields = $0 }

        if request.auth {
            if let token = AuthProvider.instance.token?.access_token {
                urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
            }
            else {
                return Fail(error: NetworkError.noAuthToken)
                    .eraseToAnyPublisher()
            }
        }

        return URLSession.shared
            .dataTaskPublisher(for: urlRequest)
            .map { $0.data }
            .mapError { $0 }
            .eraseToAnyPublisher()
    }
}
