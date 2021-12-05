//
//  TrackFile.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 05.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

struct Mp3File: RequestType {
    typealias ResponseType = FileResponse

    let path: String

    var data: RequestData {
        return RequestData(
            path: path + "&format=json",
            method: .get,
            auth: true,
            headers: [
                "X-Retpath-Y": "https%3A%2F%2Fmusic.yandex.ru%2Fradio",
                "X-Yandex-Music-Client": "YandexMusicAPI"
            ]
        )
    }
}

struct FileResponse: Decodable {
    let s: String
    let ts: String
    let path: String
    let host: String
}
