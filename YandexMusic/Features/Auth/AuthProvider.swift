//
//  AuthProvider.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation
import Combine

final class AuthProvider {
    static let instance = AuthProvider()

    private(set) var profile: UserSettingsResponse?
    private(set) var account: Account?

    @Stored(for: .resetAuth, defaultValue: false)
    var isNeedResetAuth: Bool

    @Stored(for: .deviceId, defaultValue: "")
    private(set) var deviceId: String

    init() {
        guard deviceId.isEmpty else { return }
        deviceId = UUID().uuidString
    }

    func auth(with cookies: [HTTPCookie]) -> AnyPublisher<Void, Error> {
        cookies.forEach {
            HTTPCookieStorage.shared.setCookie($0)
        }
        return requestSettings()
            .flatMap { self.requestAccount(yandexuid: self.profile?.yandexuid) }
            .eraseToAnyPublisher()

    }

    func logout() {
        HTTPCookieStorage.shared
            .cookies?
            .forEach(HTTPCookieStorage.shared.deleteCookie)
        URLCache.shared.removeAllCachedResponses()
        URLSession.shared.invalidateAndCancel()
        isNeedResetAuth = true
        profile = nil
        account = nil
    }

    private func requestSettings() -> AnyPublisher<Void, Error> {
        UserSettingsRequest()
            .execute()
            .map { [weak self] profile -> Void in
                Analytics.shared.set(userId: profile.yandexuid)
                self?.profile = profile
            }
            .mapError { [weak self] error -> Error in
                self?.profile = nil
                self?.account = nil
                return error
            }
            .eraseToAnyPublisher()
    }

    private func requestAccount(yandexuid: String?) -> AnyPublisher<Void, Error> {
        guard let yandexuid = yandexuid else {
            return Just(())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return AccountRequest(yandexuid: yandexuid)
            .execute()
            .map { [weak self] model -> Void in
                self?.account = model.accounts.first
            }
            .eraseToAnyPublisher()
    }
}
