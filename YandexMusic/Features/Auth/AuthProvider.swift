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

    private(set) var token: TokenResponse?
    private(set) var profile: UserSettingsResponse?
    private(set) var account: Account?

    var isNeedResetAuth: Bool {
        get { UserDefaults.standard.bool(forKey: isNeedResetAuthKey) }
        set { UserDefaults.standard.set(newValue, forKey: isNeedResetAuthKey) }
    }

    func auth(with code: String) -> AnyPublisher<Void, Error> {
        requestToken(code: code)
            .flatMap { self.requestSettings() }
            .flatMap { self.requestAccount(yandexuid: self.profile?.yandexuid) }
            .eraseToAnyPublisher()
    }

    func logout() {
        isNeedResetAuth = true
        token = nil
        profile = nil
        account = nil
    }

    private func requestToken(code: String) -> AnyPublisher<Void, Error> {
        TokenRequest(code: code)
            .execute()
            .map { [weak self] token -> Void in
                self?.token = token
                self?.profile = nil
                self?.account = nil
            }
            .mapError { [weak self] error -> Error in
                self?.token = nil
                self?.profile = nil
                self?.account = nil
                return error
            }
            .eraseToAnyPublisher()
    }

    private func requestSettings() -> AnyPublisher<Void, Error> {
        UserSettingsRequest()
            .execute()
            .map { [weak self] profile -> Void in
                self?.profile = profile
            }
            .mapError { [weak self] error -> Error in
                self?.token = nil
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
