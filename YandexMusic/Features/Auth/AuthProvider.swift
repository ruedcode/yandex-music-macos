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
    static let instance = AuthProviderImpl()

//    private(set) var profile: UserSettingsResponse?
//    private(set) var account: Account?
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

//    private func refreshToken() -> AnyPublisher<Void, Error>

    func auth(code: String) -> AnyPublisher<Void, Error> {
        return AuthCodeRequest(code: code)
            .execute()
            .map { [weak self] response -> Void in
                self?.token = TokenWithTime(date: Date(), token: response)
            }
            .mapError { [weak self] error -> Error in
//                self?.profile = nil
//                self?.account = nil
                return error
            }
            .eraseToAnyPublisher()
    }

//    func auth(with cookies: [HTTPCookie]) -> AnyPublisher<Void, Error> {
//        cookies.forEach {
//            HTTPCookieStorage.shared.setCookie($0)
//        }
//        return requestSettings()
//            .flatMap { self.requestAccount(yandexuid: self.profile?.yandexuid) }
//            .eraseToAnyPublisher()
//
//    }

    func logout() {
        HTTPCookieStorage.shared
            .cookies?
            .forEach(HTTPCookieStorage.shared.deleteCookie)
        URLCache.shared.removeAllCachedResponses()
        URLSession.shared.invalidateAndCancel()
        isNeedResetAuth = true
        token = nil
//        profile = nil
//        account = nil
    }

//    private func requestSettings() -> AnyPublisher<Void, Error> {
//        UserSettingsRequest()
//            .execute()
//            .map { [weak self] profile -> Void in
//                Analytics.shared.set(userId: profile.uid)
//                self?.profile = profile
//            }
//            .mapError { [weak self] error -> Error in
//                self?.profile = nil
//                self?.account = nil
//                return error
//            }
//            .eraseToAnyPublisher()
//    }

//    private func requestAccount(yandexuid: String?) -> AnyPublisher<Void, Error> {
//        guard let yandexuid = yandexuid else {
//            return Just(())
//                .setFailureType(to: Error.self)
//                .eraseToAnyPublisher()
//        }
//        return AccountRequest(yandexuid: yandexuid)
//            .execute()
//            .map { [weak self] model -> Void in
//                self?.account = model.accounts.first
//            }
//            .eraseToAnyPublisher()
//    }
}
