//
//  AppState.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

struct AppState {
    var auth: AuthState = AuthState()
    var station: SectionState = SectionState()
    var track: TrackState = TrackState()
    var playerSettings: PlayerSettingsState = PlayerSettingsState()
}

struct ErrorState {
    let text: String
    let button: String
    let action: AppAction

    init(
        text: String = "common-error",
        button: String = "repeat-bt-error",
        action: AppAction
    ) {
        self.text = text
        self.button = button
        self.action = action
    }
}
