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
) -> AnyPublisher<AppAction, Never> {
    switch action {
    case is AuthAction:
        return authReducer(
            state: &state.auth,
            action: action as! AuthAction
        )
    case is CollectionAction:
        return collectionReducer(
            state: &state.collection,
            action: action as! CollectionAction
        )
    case is TrackAction:
        return trackReducer(
            state: &state.track,
            action: action as! TrackAction
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
