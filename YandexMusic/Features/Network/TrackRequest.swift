//
//  Track.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 05.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

struct TrackRequest: RequestType {
    typealias ResponseType = TrackResponse
    let type: String
    let tag: String
    let queue: [(String, String)]

    var data: RequestData {
        let queue = queue.map { $0.0 + ":" + $0.1 }.joined(separator: ",").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return RequestData(
            path: String(format: Constants.Track.list, type, tag, queue),
            method: .get,
            auth: true,
            headers: [
                "X-Retpath-Y": "https%3A%2F%2Fmusic.yandex.ru%2Fradio",
                "X-Yandex-Music-Client": "YandexMusicAPI"
            ]
        )
    }
}

struct TrackResponse: Decodable {
    let tracks: [TrackDTO]
}
