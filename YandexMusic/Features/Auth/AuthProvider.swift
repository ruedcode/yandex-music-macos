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

    private(set) var token: TokenResponse?
    private(set) var profile: UserSettingsResponse?

    func auth(with code: String) -> AnyPublisher<Void, Error> {
        requestToken(code: code)
            .flatMap { self.requestSettings() }
            .eraseToAnyPublisher()
    }

    private func requestToken(code: String) -> AnyPublisher<Void, Error> {
        TokenRequest(code: code)
            .execute()
            .map { [weak self] token -> Void in
                self?.token = token
                self?.profile = nil
            }
            .mapError { [weak self] error -> Error in
                self?.token = nil
                self?.profile = nil
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
                return error
            }
            .eraseToAnyPublisher()
    }
}
