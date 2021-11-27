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
    action: CollectionAction
) -> AnyPublisher<AppAction, Never> {
    let fetcher = FetchRecommendation()
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
        state.stations = items.stations.compactMap {

            Station(
                name: $0.station.name,
                color: $0.station.icon.backgroundColor,
                image: "https://" + $0.station.icon.imageUrl.replacingOccurrences(of: "%%", with: "200x200")
            )
        }

    default:
        break
    }
    return Empty().eraseToAnyPublisher()
}

