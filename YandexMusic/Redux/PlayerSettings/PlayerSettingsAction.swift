//
//  PlayerSettingsAction.swift
//  YandexMusic
//
//  Created by Mike Price on 18.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

enum PlayerSettingsAction: AppAction {
    case fetch
    case set(PlayerSettingsDiversity, PlayerSettingsLanguage, PlayerSettingsMood)
    case updateDiversity(PlayerSettingsDiversity)
    case updateLanguage(PlayerSettingsLanguage)
    case updateMoodEnergy(PlayerSettingsMood)
    case save(PlayerSettingsDiversity, PlayerSettingsLanguage, PlayerSettingsMood)
    case error(AppAction)
}

