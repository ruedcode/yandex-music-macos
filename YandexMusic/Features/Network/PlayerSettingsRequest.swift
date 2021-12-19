//
//  PlayerSettingsRequest.swift
//  YandexMusic
//
//  Created by Mike Price on 18.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

// MARK: - Settings items

enum PlayerSettingsLanguage: String, Codable, CaseIterable, Identifiable {
    case russian
    case notRussian = "not-russian"
    case any

    var id: String { self.rawValue }
}

enum PlayerSettingsDiversity: String, Codable, CaseIterable, Identifiable {
    case favorite
    case discover
    case popular
    case `default`

    var id: String { self.rawValue }
}

enum PlayerSettingsMood: String, Codable, CaseIterable, Identifiable {
    case active
    case fun
    case calm
    case sad
    case all

    var id: String { self.rawValue }
}

// MARK: - PlayerSettings GET

struct PlayerSettingsRequest: RequestType {
    typealias ResponseType = PlayerSettingsResponse

    struct Params {
        let type: String
        let tag: String
    }

    private let params: Params

    init(params: Params) {
        self.params = params
    }

    var data: RequestData {
        return RequestData(
            path: String(
                format: Constants.Track.settings,
                params.type,
                params.tag
            ) + "?external-domain=music.yandex.ru&overembed=no",
            method: .get
        )
    }
}

struct PlayerSettingsResponse: Codable {
    struct Settings: Codable {
        let diversity: PlayerSettingsDiversity
        let language: PlayerSettingsLanguage
        let moodEnergy: PlayerSettingsMood
    }

    let settings2: PlayerSettingsResponse.Settings
}

// MARK: - PlayerSettings POST

struct UpdatePlayerSettingsRequest: RequestType {
    typealias ResponseType = UpdatePlayerSettingsResponse

    struct Params {
        let type: String
        let tag: String
        let language: PlayerSettingsLanguage
        let moodEnergy: PlayerSettingsMood
        let diversity: PlayerSettingsDiversity
    }

    private let params: Params

    init(params: Params) {
        self.params = params
    }

    var data: RequestData {
        return RequestData(
            path: String(
                format: Constants.Track.settings,
                params.type,
                params.tag
            ),
            method: .post,
            params: .urlenencoded(
                Form(
                    language: params.language,
                    moodEnergy: params.moodEnergy,
                    diversity: params.diversity
                )
            )
        )
    }

    fileprivate struct Form: Encodable {
        let language: PlayerSettingsLanguage
        let moodEnergy: PlayerSettingsMood
        let diversity: PlayerSettingsDiversity
        let sign: String = AuthProvider.instance.profile?.csrf ?? ""
        let externalDomain: String = "music.yandex.ru"
        let overembed: String = "no"

        enum CodingKeys: String, CodingKey {
            case diversity, overembed, moodEnergy, language, sign
            case externalDomain = "external-domain"
        }
    }
}

struct UpdatePlayerSettingsResponse: Codable {
    let result: Bool
}
