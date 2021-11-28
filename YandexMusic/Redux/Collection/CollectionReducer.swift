//
//  CollectionReducer.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation
import Combine

func collectionReducer(
    state: inout CollectionState,
    action: CollectionAction,
    store: Store<AppState, AppAction>
) -> AnyPublisher<AppAction, Never> {
    let fetcher = RecommendationRequest()
    switch action {
    case .fetch:
        return fetcher.execute()
            .map {
                CollectionAction.update($0)
            }
            .catch { error in
                Empty(completeImmediately: true)
            }
            .eraseToAnyPublisher()
    case .update(let items):
        let stations = items.stations.compactMap {
            Station(
                type: $0.station.id.type,
                tag: $0.station.id.tag,
                name: $0.station.name,
                color: $0.station.icon.backgroundColor,
                image: link(from: $0.station.icon.imageUrl)
            )
        }
        state.stations = stations
        if state.selected == nil, let station = stations.first {
            state.selected = station
            store.send(TrackAction.fetch(type: station.type, tag: station.tag, queue: []))
        }

    default:
        break
    }
    return Empty().eraseToAnyPublisher()
}

