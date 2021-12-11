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
    default:
        break
    }
}
