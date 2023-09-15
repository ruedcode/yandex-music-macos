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
    case AuthAction.logout:
        return Just(AccountAction.reset)
            .merge(with: Just(TrackAction.resetPlayer))
            .merge(with: Just(BaseAction.resetState))
            .eraseToAnyPublisher()

    default:
        break
    }

    return nil
}
