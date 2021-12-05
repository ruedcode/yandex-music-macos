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

    let params: Params

    var data: RequestData {
        return RequestData(
            path: String(
                format: Constants.Track.feedback,
                params.type,
                params.tag,
                params.action.rawValue,
                params.trackId,
                params.albumId
            ),
            method: .post,
            auth: true,
            headers: [
                "X-Retpath-Y": "https%3A%2F%2Fmusic.yandex.ru%2Fradio",
                "X-Yandex-Music-Client": "YandexMusicAPI"
            ]
        )
    }

    enum Action: String {
        case radioStarted
        case trackStarted
        case skip
    }

    struct Params {
        let type: String
        let tag: String
        let trackId: String
        let albumId: String
        let action: Action
    }
}

struct TrackFeedbackResponse: Decodable {
    let result: String
    let info: String
}
