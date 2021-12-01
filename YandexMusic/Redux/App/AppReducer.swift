//
//  AppReducer.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation
import Combine
import CloudKit

func appReducer(
    state: inout AppState,
    action: AppAction
) -> AnyPublisher<AppAction, Never>? {
    switch action {
    case is AuthAction:
        return authReducer(
            state: &state.auth,
            action: action
        )
    case is CollectionAction:
        return collectionReducer(
            state: &state.collection,
            action: action
        )
    case is TrackAction:
        return trackReducer(
            state: &state.track,
            action: action
        )
    case is BaseAction:
        switch action as? BaseAction {
        case let .dumb(error):
            print("-->> error: \(error.localizedDescription)")
        case .none:
            break
        }
    default: break
    }
    return Empty().eraseToAnyPublisher()
}
