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
            auth: true
        )
    }
}
