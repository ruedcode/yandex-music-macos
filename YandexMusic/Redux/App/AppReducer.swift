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
    action: AppAction,
    store: Store<AppState, AppAction>
) -> AnyPublisher<AppAction, Never> {
    switch action {
    case is AuthAction:
        return authReducer(
            state: &state.auth,
            action: action as! AuthAction,
            store: store
        )
    case is CollectionAction:
        return collectionReducer(
            state: &state.collection,
            action: action as! CollectionAction,
            store: store
        )
    case is TrackAction:
        return trackReducer(
            state: &state.track,
            action: action as! TrackAction,
            store: store
        )
    default: break
    }
    return Empty().eraseToAnyPublisher()
}
