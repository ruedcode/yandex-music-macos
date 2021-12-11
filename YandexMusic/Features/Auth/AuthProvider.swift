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

    private let isNeedResetAuthKey = "isNeedResetAuth"
    private let deviceIdKey = "deviceId"

    private(set) var profile: UserSettingsResponse?
    private(set) var account: Account?

    var isNeedResetAuth: Bool {
        get { UserDefaults.standard.bool(forKey: isNeedResetAuthKey) }
        set { UserDefaults.standard.set(newValue, forKey: isNeedResetAuthKey) }
    }

    var deviceId: String {
        get {
            if let deviceId = UserDefaults.standard.string(forKey: deviceIdKey) {
                return deviceId
            }
            else {
                let deviceId = UUID().uuidString
                UserDefaults.standard.set(deviceId, forKey: deviceIdKey)
                return deviceId
            }

        }
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
