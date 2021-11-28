//
//  TrackReducer.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 28.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation
import Combine

func trackReducer(
    state: inout TrackState,
    action: TrackAction,
    store: Store<AppState, AppAction>
) -> AnyPublisher<AppAction, Never> {
    switch action {
    case let .fetch(type, tag, _):
        return TrackRequest(type: type, tag: tag, queue: []).execute()
            .map {
                TrackAction.update($0)
            }
            .catch { error in
                Empty(completeImmediately: true)
            }
            .eraseToAnyPublisher()
    case let .update(response):
        if let current = response.tracks.first {
            state.current = Track(model: current)
        }
        if let next = response.tracks.suffix(1).first {
            state.next = Track(model: next)
        }
    case .tooglePlay:
        state.isPlaying = !state.isPlaying
    }
    return Empty().eraseToAnyPublisher()
}
