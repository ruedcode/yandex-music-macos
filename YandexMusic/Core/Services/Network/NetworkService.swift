//
//  NetworkService.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Combine
import Foundation
import AppKit

protocol NetworkDispatcher {
    func dispatch(request: RequestData, isAuth: Bool) -> AnyPublisher<Data, Error>
}

struct URLSessionNetworkDispatcher: NetworkDispatcher {
    static let instance = URLSessionNetworkDispatcher(authProvider: AssemblyRegistrator.instance.assembly.resolve(strategy: .last))

    private let authProvider: AuthProvider

    private init(authProvider: AuthProvider) {
        self.authProvider = authProvider
    }

    func dispatch(request: RequestData, isAuth: Bool) -> AnyPublisher<Data, Error> {
        guard let url = makeLocalizedUrl(string: request.path) else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }

        let requestMaker: (RequestData) -> AnyPublisher<Data, Error> = { request in
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = request.method.rawValue
            var headers = Constants.Common.baseHeaders

            request.params.flatMap { params in
                urlRequest.httpBody = params.data
                headers.merge(params.headers) { $1 }
            }

            request.headers.flatMap {
                headers.merge($0) { $1 }
            }

            urlRequest.allHTTPHeaderFields = headers

            log("Request started:\n\(urlRequest.asCURL)", level: .debug)

            return URLSession.shared
                .dataTaskPublisher(for: urlRequest)
                .map(mapResponse)
                .mapError { $0 }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }

        if isAuth {
            return authProvider.enrichAuth(request: request)
                .flatMap {
                    requestMaker($0)
                }.eraseToAnyPublisher()
        }
        return requestMaker(request)


    }

    private func mapResponse(data: Data, response: URLResponse) -> Data {
        var logMessage = "Request finished with:"
        if let httpResponse = response as? HTTPURLResponse {
            if [401, 403].contains(httpResponse.statusCode) {
                DispatchQueue.main.async {
                    (NSApp.delegate as? AppDelegate)?.auth()
                }
            }
            logMessage += "\nResponse code: \(httpResponse.statusCode)"
        }
        logMessage += "\nResponse data: \(String(data: data, encoding: .utf8) ?? "none")"
        log(logMessage, level: .debug)
        return data
    }

    private func makeLocalizedUrl(string: String) -> URL? {
        guard var urlComponents = URLComponents(string: string) else {
            return nil
        }
        var queryItems = urlComponents.queryItems ?? []

        if !queryItems.contains(where: {
            $0.name == "lang"
        }){
            queryItems.append(
                URLQueryItem(
                    name: "lang", value: NSLocale.current.languageCode ?? Constants.Common.locale
                )
            )
        }
        urlComponents.queryItems = queryItems
        return urlComponents.url
    }
}

private extension URLRequest {
    var asCURL: String {
        guard let url = url else { return "" }
        var baseCommand = #"curl "\#(url.absoluteString)""#

        if httpMethod == "HEAD" {
            baseCommand += " --head"
        }

        var command = [baseCommand]

        if let method = httpMethod, method != "GET" && method != "HEAD" {
            command.append("-X \(method)")
        }

        if let headers = allHTTPHeaderFields {
            for (key, value) in headers where key != "Cookie" {
                command.append("-H '\(key): \(value)'")
            }
        }

        if let data = httpBody, let body = String(data: data, encoding: .utf8) {
            command.append("-d '\(body)'")
        }

        return command.joined(separator: " \\\n\t")
    }

}
