//
//  NetworkService.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

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
                if let name = $0.element.key as? String,
                   let value = $0.element.value as? String {
                    items.append(URLQueryItem(name: name, value: value))
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
        dispatcher: NetworkDispatcher = URLSessionNetworkDispatcher.instance,
        onComplete: @escaping (Result<ResponseType, Error>) -> Void
    ) {
        dispatcher.dispatch(request: self.data) { result in
            switch result {
            case let .success(responseData):
                do {
                    let jsonDecoder = JSONDecoder()
                    let result = try jsonDecoder.decode(ResponseType.self, from: responseData)
                    DispatchQueue.main.async {
                        onComplete(.success(result))
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        onComplete(.failure(error))
                    }
                }
            case let .failure(error):
                DispatchQueue.main.async {
                    onComplete(.failure(error))
                }
            }
        }
    }
}

protocol NetworkDispatcher {
    func dispatch(request: RequestData, onComplete: @escaping (Result<Data, Error>) -> Void)
}

struct URLSessionNetworkDispatcher: NetworkDispatcher {
    static let instance = URLSessionNetworkDispatcher()
    private init() {}

    func dispatch(request: RequestData, onComplete: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: request.path) else {
            onComplete(.failure(NetworkError.invalidURL))
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue

        if let params = request.params {
            urlRequest.httpBody = params.data
            params.headers.forEach {
                urlRequest.setValue($0.value, forHTTPHeaderField: $0.key)
            }
        }

        if let headers = request.headers {
            urlRequest.allHTTPHeaderFields = headers
        }

        if request.auth {
            if let token = AuthProvider.instance.token?.access_token {
                urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
            }
            else {
                onComplete(.failure(NetworkError.noAuthToken))
                return
            }
        }

        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                onComplete(.failure(error))
                return
            }

            guard let _data = data else {
                onComplete(.failure(NetworkError.emptyResponse))
                return
            }

            onComplete(.success(_data))
        }.resume()
    }
}
