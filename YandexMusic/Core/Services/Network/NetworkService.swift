//
//  NetworkService.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Aaron Wright. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case emptyResponse
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
    let params: [String: Any?]?
    let headers: [String: String]?

    init (
        path: String,
        method: HTTPMethod = .get,
        params: [String: Any?]? = nil,
        headers: [String: String]? = nil
    ) {
        self.path = path
        self.method = method
        self.params = params
        self.headers = headers
    }
}

protocol RequestType {
    associatedtype ResponseType: Codable
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

        do {
            if let params = request.params {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
            }
        } catch let error {
            onComplete(.failure(error))
            return
        }

        if let headers = request.headers {
            urlRequest.allHTTPHeaderFields = headers
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
