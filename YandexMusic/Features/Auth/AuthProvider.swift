//
//  AuthProvider.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation
import Combine

protocol AuthProvider {
    var isAuth: Bool { get }
    var onLogout: () -> Void { get set }
    func auth(code: String) -> AnyPublisher<Void, Error>
    func enrichAuth(request: RequestData) -> AnyPublisher<RequestData, Error>
    func logout()
}

fileprivate struct TokenWithTime {
    let date: Date
    let token: AuthCodeResponse
    var isExpired: Bool {
        let date = Date()
        return date > date.addingTimeInterval(TimeInterval(token.expiresIn))
    }
}

final class AuthProviderImpl: AuthProvider {

    var onLogout: () -> Void = {}

    private var token: TokenWithTime?

    @Stored(for: .resetAuth, defaultValue: false)
    var isNeedResetAuth: Bool

    @Stored(for: .deviceId, defaultValue: "")
    private(set) var deviceId: String

    var isAuth: Bool {
        guard let token = token, !token.isExpired else {
            return false
        }
        return true
    }

    init() {
        guard deviceId.isEmpty else { return }
        deviceId = UUID().uuidString
    }

    func enrichAuth(request: RequestData) -> AnyPublisher<RequestData, Error> {
        var headers = request.headers ?? [:]
        if isAuth, let token = token {
            headers["Authorization"] = "\(token.token.tokenType) \(token.token.accessToken)"
            return Just(
                RequestData(
                    path: request.path,
                    method: request.method,
                    params: request.params,
                    headers: headers
                )
            )
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        }
        //TODO: - refres token
//        else if let token = token, !isAuth {
//
//        }
        return Just(request)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()

    }

    func auth(code: String) -> AnyPublisher<Void, Error> {
        return AuthCodeRequest(code: code)
            .execute()
            .map { [weak self] response -> Void in
                self?.token = TokenWithTime(date: Date(), token: response)
            }
            .mapError { [weak self] error -> Error in
                self?.token = nil
                return error
            }
            .eraseToAnyPublisher()
    }

    func logout() {
        HTTPCookieStorage.shared
            .cookies?
            .forEach(HTTPCookieStorage.shared.deleteCookie)
        URLCache.shared.removeAllCachedResponses()
        URLSession.shared.invalidateAndCancel()
        isNeedResetAuth = true
        token = nil
    }
}
