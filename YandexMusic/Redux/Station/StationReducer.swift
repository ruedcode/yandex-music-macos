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
        state.groups = items.compactMap(StationGroup.init).sorted
        state.stationGroup = state.groups.first
        let stations = state.stationGroup?.stations
        state.stations = stations ?? []
        if state.station == nil, let station = stations?.first {
            return StationAction.select(station, andPlay: false).next
        }

    case let StationAction.selectGroup(stationGroup, andPlay):
        state.stationGroup = stationGroup
        state.stations = stationGroup.stations
        if state.station == nil, let station = state.stations.first {
            return StationAction.select(station, andPlay: andPlay).next
        }

    case let StationAction.select(station, andPlay):
        guard state.station != station else {
            return nil
        }
        state.station = station
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

