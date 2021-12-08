//
//  UserSettings.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 05.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

struct UserSettingsRequest: RequestType {
    typealias ResponseType = UserSettingsResponse
    
    var data: RequestData {
        return RequestData(
            path: Constants.Auth.userSettings,
            method: .get,
            auth: true,
            headers: [
                "X-Retpath-Y": "https%3A%2F%2Fmusic.yandex.ru%2Fradio",
                "X-Yandex-Music-Client": "YandexMusicAPI"
            ]
        )
    }
}

struct UserSettingsResponse: Codable {
    let csrf: String
    let freshCsrf: String
    let login: String
    let uid: String
    let yandexuid: String
    let premium: Bool
    let device_id: String
}
