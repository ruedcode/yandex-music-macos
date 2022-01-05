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

enum LoadingState: Equatable {

    case loading
    case error(ErrorState)
    case success
    case initial

    static func == (lhs: LoadingState, rhs: LoadingState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.error, .error):
            return true
        case (.success, .success):
            return true
        case (.initial, .initial):
            return true
        default:
            return false
        }
    }
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
