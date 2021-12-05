//
//  TrackFeedback.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 05.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation


struct TrackFeedbackRequest: RequestType {
    typealias ResponseType = TrackFeedbackResponse

    let type: String
    let tag: String
    let trackId: String
    let albumId: String

    var data: RequestData {
        return RequestData(
            path: String(format: Constants.Track.feedback, type, tag, trackId, albumId),
            method: .post,
            auth: true,
            headers: [
                "X-Retpath-Y": "https%3A%2F%2Fmusic.yandex.ru%2Fradio",
                "X-Yandex-Music-Client": "YandexMusicAPI"
            ]
        )
    }
}

struct TrackFeedbackResponse: Decodable {
    let result: String
    let info: String
}
