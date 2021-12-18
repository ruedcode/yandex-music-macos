//
//  PlayerSettingsMiddleware.swift
//  YandexMusic
//
//  Created by Mike Price on 18.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

var playerSettingsMiddleware: Middleware<AppState, AppAction> = { store, action in
    switch action {
    case PlayerSettingsAction.fetch:
        PlayerSettingsRequest()
            .execute()
            .sink(receiveCompletion: { result in
                guard case .failure = result else { return }
                store.send(PlayerSettingsAction.error(action))
            }, receiveValue: {
                let item = $0.settings2
                store.send(PlayerSettingsAction.set(item.diversity, item.language, item.moodEnergy))
            })
            .store(in: &store.effectCancellables)

    case let PlayerSettingsAction.save(diversity, language, moodEnergy):
        UpdatePlayerSettingsRequest(language: language,
                                    moodEnergy: moodEnergy,
                                    diversity: diversity)
            .execute()
            .sink { result in
                guard case .failure = result else { return }
                store.send(PlayerSettingsAction.error(action))
            } receiveValue: { _ in }
            .store(in: &store.effectCancellables)

    default:
        break
    }
}
