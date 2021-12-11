//
//  AccountRequest.swift
//  YandexMusic
//
//  Created by Mike Price on 11.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

struct AccountRequest: RequestType {
    typealias ResponseType = AccountResponse

    private let yandexuid: String

    init(yandexuid: String) {
        self.yandexuid = yandexuid
    }

    var data: RequestData {
        return RequestData(
            path: Constants.Auth.account + "?popup=yes&yu=\(yandexuid)",
            method: .get,
            auth: true,
            headers: [
                "X-Retpath-Y": "https%3A%2F%2Fmusic.yandex.ru%2Fradio",
                "X-Yandex-Music-Client": "YandexMusicAPI"
            ]
        )
    }
}

// MARK: - AccountResponse
struct AccountResponse: Codable {
    let accounts: [Account]
}

// MARK: - Account
struct Account: Codable {
    let displayName: String
    let uid: Int
    let method: String
    let avatar: Avatar

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case uid, method, avatar
    }
}

// MARK: - Avatar
struct Avatar: Codable {
    let avatarDefault: String
    let empty: Bool

    enum CodingKeys: String, CodingKey {
        case avatarDefault = "default"
        case empty
    }
}
