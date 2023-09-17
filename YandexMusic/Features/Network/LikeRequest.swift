//
//  LikeRequest.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 05.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

struct LikeRequest: RequestType {
    typealias ResponseType = LikeResponse

    let params: Params

    var data: RequestData {
        return RequestData(
            path: params.like
            ? Constants.Track.like.format(from: ["userId": params.userId])
            : Constants.Track.unlike.format(from: ["userId": params.userId]),
            method: .post,
            params: .urlenencoded(
                Form(trackIds: params.trackId)
            )
        )
    }

    struct Params {
        let trackId: String
        let albumId: String
        let userId: String
        let like: Bool
    }

    fileprivate struct Form: Encodable {
        let trackIds: String
    }
}

struct LikeResponse: Decodable {
}
