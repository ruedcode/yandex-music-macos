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
        return requestToken(code: code).flatMap { _ in
            self.requestSettings().eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }

    func logout() {
        token = nil
        profile = nil
    }

    private func requestToken(code: String) -> AnyPublisher<Void, Error> {
        return Future() { promise in
            TokenRequest(code: code).execute { [weak self] result in
                switch result {
                case let .success(token):
                    self?.token = token
                    self?.profile = nil
                    promise(.success(()))
                case let .failure(error):
                    self?.token = nil
                    self?.profile = nil
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }

    private func requestSettings() -> AnyPublisher<Void, Error> {
        return Future() { promise in
            UserSettingsRequest().execute { [weak self] result in
                switch result {
                case let .success(profile):
                    self?.profile = profile
                    promise(.success(()))
                case let .failure(error):
                    self?.profile = nil
                    self?.token = nil
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
}
