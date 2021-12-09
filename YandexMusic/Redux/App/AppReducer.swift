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
    case is SectionAction:
        return sectionReducer(
            state: &state.section,
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
            log(error)
        case .none:
            break
        }
    default: break
    }
    return nil
}
