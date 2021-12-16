//
//  SettingsHelper.swift
//  YandexMusic
//
//  Created by Mike Price on 13.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

enum AppIconMode: String, CaseIterable {
    case both
    // TODO: Uncomment after clarifying appearance of main screen without a context menu
//    case dock
    case context
}

final class SettingsStorage {
    static let shared = SettingsStorage()

    @Stored(for: .appIconMode, defaultValue: AppIconMode.both.rawValue)
    private var _appIconMode: String

    private init() {}

    var appIconMode: AppIconMode {
        set { _appIconMode = newValue.rawValue }
        get { AppIconMode(rawValue: _appIconMode) ?? .both }
    }
}
