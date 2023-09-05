//
//  Stored.swift
//  YandexMusic
//
//  Created by Mike Price on 12.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

enum StoredKeys: String {
    case resetAuth = "is_need_reset_auth"
    case musicVolume = "music_volume"
    case lastSelectedStationTag = "last_selected_station_tag"
    case lastSelectedStationGroupId = "last_selected_station_group_id"
    case deviceId = "deviceId"
    case appIconMode = "app_icon_mode"
    case showCurrentTrackAlert = "show_current_track_alert"

    fileprivate static let cleanable: [StoredKeys] = [.musicVolume, .lastSelectedStationTag, .lastSelectedStationGroupId]
}

@propertyWrapper
struct Stored<Value> {
    let key: StoredKeys
    let defaultValue: Value

    init(for key: StoredKeys, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: Value {
        get { UserDefaults.standard.object(forKey: key.rawValue) as? Value ?? defaultValue }
        set { UserDefaults.standard.set(newValue, forKey: key.rawValue) }
    }

    static func clear() {
        StoredKeys.cleanable
            .forEach { UserDefaults.standard.removeObject(forKey: $0.rawValue) }
    }
}
