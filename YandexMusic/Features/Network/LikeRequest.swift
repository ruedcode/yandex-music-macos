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
            path: String(
                format: params.like ? Constants.Track.like: Constants.Track.unlike,
                params.trackId,
                params.albumId
            ),
            method: .post,
            params: .urlenencoded(
                Form()
            )
        )
    }

    struct Params {
        let trackId: String
        let albumId: String
        let like: Bool
    }

    fileprivate struct Form: Encodable {
        let from: String = "web-radio-user-saved"
        let sign: String = AuthProviderImpl.instance.profile?.csrf ?? ""
        let overembed: String = "no"
    }
}

struct LikeResponse: Decodable {
    let success: Bool
    let act: String
}
