//
//  CollectionReducer.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation
import Combine

func sectionReducer(
    state: inout SectionState,
    action: AppAction
) -> AnyPublisher<AppAction, Never>? {
    let fetcher = RecommendationRequest()
    switch action {
    case SectionAction.fetch:
        return fetcher.execute()
            .map {
                SectionAction.update($0)
            }
            .ignoreError()
            .eraseToAnyPublisher()
    case SectionAction.update(let items):
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
            return SectionAction.select(station, andPlay: false).next
        }
    case let SectionAction.select(station, andPlay):
        guard state.selected != station else {
            return nil
        }
        state.selected = station
        return TrackAction.fetch(
            type: station.type,
            tag: station.tag,
            queue: [],
            andPlay: andPlay
        ).next
    default:
        break
    }
    return nil
}

