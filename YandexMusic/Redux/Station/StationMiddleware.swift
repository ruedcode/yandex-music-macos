//
//  SectionMiddleware.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 09.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

var stationMiddleware: Middleware<AppState, AppAction> = { store, action in
    switch action {
    case StationAction.fetch:
        LibraryRequest()
            .execute()
            .ignoreError()
            .sink { 
                store.send(StationAction.update($0.groups))
            }
            .store(in: &store.effectCancellables)
    case let StationAction.select(station, andPlay):
        guard store.state.station.station == station, andPlay else {
            return
        }
        store.send(store.state.track.isPlaying ? TrackAction.pause : TrackAction.play)
    default:
        break
    }
}
