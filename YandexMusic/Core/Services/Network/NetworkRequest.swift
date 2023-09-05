//
//  NetworkData.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 02.09.2023.
//  Copyright © 2023 Eugene Kalyada. All rights reserved.
//

import Combine
import Foundation

protocol RequestType {
    associatedtype ResponseType: Decodable
    var data: RequestData { get }

    var isAuth: Bool { get }

    var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy { get }
    var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy { get }
}


extension RequestType {
    var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy {
        return JSONDecoder.KeyDecodingStrategy.useDefaultKeys
    }

    var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy {
        JSONDecoder.DateDecodingStrategy.iso8601
    }

    var isAuth: Bool { true }

}

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
    let path: String
    let method: HTTPMethod
    let params: Params?
    let headers: [String: String]?

    init(
        path: String,
        method: HTTPMethod = .get,
        params: Params? = nil,
        headers: [String: String]? = nil
    ) {
        self.path = path
        self.method = method
        self.params = params
        self.headers = headers
    }

    struct Params {
        var data: Data?
        var headers: [String: String]

        static func json<T: Encodable>(
            _ model: T,
            keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy? = nil,
            dateEncodingStrategy: JSONEncoder.DateEncodingStrategy? = nil
        ) -> Params {
            let encoder = JSONEncoder()
            if let keyEncodingStrategy = keyEncodingStrategy {
                encoder.keyEncodingStrategy = keyEncodingStrategy
            }
            if let dateEncodingStrategy = dateEncodingStrategy {
                encoder.dateEncodingStrategy = dateEncodingStrategy
            }
            return Params(
                data: try? encoder.encode(model),
                headers: ["Content-Type": "application/json"]
            )
        }

        static func urlenencoded<T: Encodable>(_ model: T, isAuth: Bool = false) -> Params {
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

extension RequestType {
    func execute (
        dispatcher: NetworkDispatcher = URLSessionNetworkDispatcher.instance
    ) -> AnyPublisher<ResponseType, Error> {

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = keyDecodingStrategy
        decoder.dateDecodingStrategy = dateDecodingStrategy

        return dispatcher.dispatch(request: self.data, isAuth: self.isAuth)
            .decode(type: ResponseType.self, decoder: decoder)
            .mapError {
                log("Request error: \($0)", level: .error)
                return $0
            }
            .eraseToAnyPublisher()
    }
}
