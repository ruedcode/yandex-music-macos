//
//  CollectionReducer.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation
import Combine

private struct StationStore {
    @Stored(for: .lastSelectedStationTag, defaultValue: nil)
    static var lastSelectedStationTag: String?

    @Stored(for: .lastSelectedStationGroupId, defaultValue: nil)
    static var lastSelectedStationGroupId: String?
}


func stationReducer(
    state: inout SectionState,
    action: AppAction
) -> AnyPublisher<AppAction, Never>? {
    switch action {
    case StationAction.error:
        state.hasError = true

    case StationAction.fetch:
        state.hasError = false

    case StationAction.reload:
        state = SectionState()
        return Just(TrackAction.pause)
            .merge(with: Just(TrackAction.clear))
            .merge(with: Just(StationAction.fetch))
            .eraseToAnyPublisher()

    case StationAction.update(let items):
        state.groups = items.compactMap(StationGroup.init).sorted
        state.stationGroup = state.groups.first { $0.id == StationStore.lastSelectedStationGroupId }
            ?? state.groups.first
        let stations = state.stationGroup?.stations
        state.stations = stations ?? []
        if
            state.station == nil,
            let station = stations?.first(where: { $0.tag == StationStore.lastSelectedStationTag })
                ?? stations?.first
        {
            return StationAction.select(station, andPlay: false).next
        }

    case let StationAction.selectGroup(stationGroup, andPlay):
        StationStore.lastSelectedStationGroupId = stationGroup.id
        state.stationGroup = stationGroup
        state.stations = stationGroup.stations
        if state.station == nil, let station = state.stations.first {
            return StationAction.select(station, andPlay: andPlay).next
        }

    case let StationAction.select(station, andPlay):
        guard state.station != station else {
            return nil
        }
        StationStore.lastSelectedStationTag = station.tag
        state.station = station
        if andPlay {
            return Just(TrackAction.fetch(type: station.type, tag: station.tag, queue: [], andPlay: andPlay))
                .merge(with: Just(PlayerSettingsAction.reset))
                .eraseToAnyPublisher()
        } else {
            return Just(TrackAction.fetch(type: station.type, tag: station.tag, queue: [], andPlay: andPlay))
                .eraseToAnyPublisher()
        }
    default:
        break
    }
    return nil
}

