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
    private(set) var token: Token?


    func requestToken(code: String) -> AnyPublisher<Void, Error> {
        return Future() { promise in
            FetchToken(code: code).execute { [weak self] result in
                switch result {
                case let .success(token):
                    self?.token = token
                    promise(.success(()))
                case let  .failure(error):
                    self?.token = nil
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()

    }
}
