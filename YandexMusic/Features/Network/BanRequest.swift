//
//  BanRequest.swift
//  YandexMusic
//
//  Created by Mike Price on 11.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

struct BanRequest: RequestType {
    typealias ResponseType = BanResponse

    let params: Params

    var data: RequestData {
        return RequestData(
            path: String(
                format: Constants.Track.ban,
                params.trackId,
                params.albumId
            ),
            method: .post,
            auth: true,
            params: .urlenencoded(
                Form()
            ),
            headers: [
                "X-Retpath-Y": "https%3A%2F%2Fmusic.yandex.ru%2Fradio",
                "X-Yandex-Music-Client": "YandexMusicAPI"
            ]
        )
    }

    struct Params {
        let trackId: String
        let albumId: String
    }

    fileprivate struct Form: Encodable {
        let from: String = "web-radio-user-saved"
        let sign: String = AuthProvider.instance.profile?.csrf ?? ""
        let overembed: String = "no"
    }
}

struct BanResponse: Decodable {
    let success: Bool
    let act: String
}
