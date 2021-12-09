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
                var stations: [StationDTO] = []
                stations.append(contentsOf: $0.types.user.children)
                stations.append(contentsOf: $0.types.activity.children)
                stations.append(contentsOf: $0.types.author.children)
                stations.append(contentsOf: $0.types.epoch.children)
                stations.append(contentsOf: $0.types.genre.children)
                stations.append(contentsOf: $0.types.mood.children)
                store.send(StationAction.update(stations))
            }
            .store(in: &store.effectCancellables)
    default:
        break
    }
}
