//
//  AuthReducer.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation
import Combine

func authReducer(
    state: inout AuthState,
    action: AuthAction
) -> AnyPublisher<AppAction, Never> {
    switch action {
    case .fetchToken(let code):
        return AuthProvider.instance
            .requestToken(code: code)
            .map {
                AuthAction.updateToken
            }
            .catch { _ in
                Empty(completeImmediately: true)
            }
            .eraseToAnyPublisher()
    case .updateToken:
        state = AuthProvider.instance.token != nil ? .authorized : .unauthorized

    default:
        break
    }
    return Empty().eraseToAnyPublisher()
}
