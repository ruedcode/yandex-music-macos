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
    action: AppAction
) -> AnyPublisher<AppAction, Never>? {
    switch action {
    case AuthAction.updateToken:
        state = AuthProvider.instance.token != nil ? .authorized : .unauthorized

    case AuthAction.logout:
        return Just(AuthAction.updateToken)
            .eraseToAnyPublisher()

    default:
        break
    }

    return nil
}
