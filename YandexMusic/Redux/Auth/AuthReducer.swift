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
    case AuthAction.update:
        state.mode = AuthProvider.instance.token != nil ? .authorized : .unauthorized
        state.userName = AuthProvider.instance.account?.displayName ?? AuthProvider.instance.profile?.login ?? ""
        state.avatarHash = AuthProvider.instance.account?.avatar.avatarDefault

    case AuthAction.logout:
        Analytics.shared.log(event: .logout)
        Analytics.shared.set(userId: nil)
        return Just(AuthAction.update)
            .merge(with: Just(TrackAction.resetPlayer))
            .merge(with: Just(BaseAction.resetState))
            .eraseToAnyPublisher()

    default:
        break
    }

    return nil
}
