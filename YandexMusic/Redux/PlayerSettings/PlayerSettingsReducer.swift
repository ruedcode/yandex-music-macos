//
//  PlayerSettingsReducer.swift
//  YandexMusic
//
//  Created by Mike Price on 18.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Combine

func playerSettingsReducer(
    state: inout PlayerSettingsState,
    action: AppAction
) -> AnyPublisher<AppAction, Never>? {
    switch action {
    case PlayerSettingsAction.error(let repeatAction):
        state.isLoading = false
        state.error = ErrorState(action: repeatAction)

    case PlayerSettingsAction.fetch:
        state.error = nil
        state.isLoading = true

    case PlayerSettingsAction.updateDiversity(let item) where state.diversity != item:
        state.diversity = item
        return PlayerSettingsAction
            .save(state.diversity, state.language, state.moodEnergy)
            .next

    case PlayerSettingsAction.updateLanguage(let item) where state.language != item:
        state.language = item
        return PlayerSettingsAction
            .save(state.diversity, state.language, state.moodEnergy)
            .next

    case PlayerSettingsAction.updateMoodEnergy(let item) where state.moodEnergy != item:
        state.moodEnergy = item
        return PlayerSettingsAction
            .save(state.diversity, state.language, state.moodEnergy)
            .next

    case let PlayerSettingsAction.set(diversity, language, moodEnergy):
        state.isLoading = false
        state.diversity = diversity
        state.language = language
        state.moodEnergy = moodEnergy
        return Just(BaseAction.resetState)
            .merge(with: Just(StationAction.fetch))
            .eraseToAnyPublisher()

    default:
        break
    }
    return nil
}
