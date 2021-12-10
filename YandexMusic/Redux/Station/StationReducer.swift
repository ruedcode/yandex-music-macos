//
//  CollectionReducer.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation
import Combine

func stationReducer(
    state: inout SectionState,
    action: AppAction
) -> AnyPublisher<AppAction, Never>? {
    switch action {
    case StationAction.update(let items):
        let stations = items.compactMap(Station.init)
        state.stations = stations
        if state.selected == nil, let station = stations.first {
            return StationAction.select(station, andPlay: false).next
        }
    case let StationAction.select(station, andPlay):
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

