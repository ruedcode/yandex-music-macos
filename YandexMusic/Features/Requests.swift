//
//  Requests.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 28.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

struct LibraryRequest: RequestType {
    typealias ResponseType = LibraryResponse

    var data: RequestData {
        return RequestData(
            path: Constants.Collection.library,
            method: .get,
            auth: true
        )
    }
}

struct RecommendationRequest: RequestType {
    typealias ResponseType = RecomendationResponse

    var data: RequestData {
        return RequestData(
            path: Constants.Collection.recommendation,
            method: .get,
            auth: true
        )
    }
}

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

struct Mp3Request: RequestType {
    typealias ResponseType = Mp3Response
    let trackId: String
    let albumId: String

    var data: RequestData {
        return RequestData(
            path: String(format: Constants.Track.mp3, trackId, albumId),
            method: .get,
            auth: true,
            headers: [
                "X-Retpath-Y": "https%3A%2F%2Fmusic.yandex.ru%2Fradio",
                "X-Yandex-Music-Client": "YandexMusicAPI"
            ]
        )
    }
}

struct FileRequest: RequestType {
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
