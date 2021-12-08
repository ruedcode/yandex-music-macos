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

struct UserSettingsResponse: Decodable {
    let csrf: String
    let freshCsrf: String
    let login: String?
    let uid: String
    let yandexuid: String
    let premium: Bool
    let deviceId: String

    enum CodingKeys: String, CodingKey {
        case csrf
        case freshCsrf
        case login
        case uid
        case yandexuid
        case premium
        case deviceId = "device_id"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        csrf = try values.decode(String.self, forKey: .csrf)
        freshCsrf = try values.decode(String.self, forKey: .freshCsrf)
        login = try values.decodeIfPresent(String.self, forKey: .login)
        uid = try values.decodeIfPresent(Int64.self, forKey: .uid)?.description
            ?? (try values.decode(String.self, forKey: .uid))
        yandexuid = try values.decode(String.self, forKey: .yandexuid)
        premium = try values.decode(Bool.self, forKey: .premium)
        deviceId = try values.decode(String.self, forKey: .deviceId)
    }
}
