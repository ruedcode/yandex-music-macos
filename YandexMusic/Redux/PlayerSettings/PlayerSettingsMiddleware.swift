//
//  PlayerSettingsMiddleware.swift
//  YandexMusic
//
//  Created by Mike Price on 18.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

var playerSettingsMiddleware: Middleware<AppState, AppAction> = {assembly, store, action in
    switch action {
    case PlayerSettingsAction.fetch:
        guard
            let type: String = store.state.station.station?.type,
            let tag: String = store.state.station.station?.tag
        else { return }
        PlayerSettingsRequest(params: PlayerSettingsRequest.Params(type: type, tag: tag))
            .execute()
            .sink(receiveCompletion: { result in
                guard case .failure = result else { return }
                store.send(PlayerSettingsAction.error(action))
            }, receiveValue: {
                let item = $0.settings2
                store.send(PlayerSettingsAction.set(
                    item.diversity,
                    item.language,
                    item.moodEnergy
                ))
            })
            .store(in: &store.effectCancellables)

    case let PlayerSettingsAction.save(diversity, language, moodEnergy):
        guard
            let type: String = store.state.station.station?.type,
            let tag: String = store.state.station.station?.tag
        else { return }
        let params = UpdatePlayerSettingsRequest.Params(
            type: type,
            tag: tag,
            language: language,
            moodEnergy: moodEnergy,
            diversity: diversity
        )
        UpdatePlayerSettingsRequest(params: params)
            .execute()
            .sink { result in
                guard case .failure = result else { return }
                store.send(PlayerSettingsAction.error(action))
            } receiveValue: { _ in
                store.send(StationAction.reload)
            }
            .store(in: &store.effectCancellables)

    default:
        break
    }
}
