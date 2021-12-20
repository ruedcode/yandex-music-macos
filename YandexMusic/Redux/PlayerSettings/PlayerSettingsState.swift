//
//  PlayerSettingsState.swift
//  YandexMusic
//
//  Created by Mike Price on 18.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

struct PlayerSettingsState {
    var diversity: PlayerSettingsDiversity = .default
    var language: PlayerSettingsLanguage = .any
    var moodEnergy: PlayerSettingsMood = .all
    var isLoading: Bool = false
    var error: ErrorState?
}
