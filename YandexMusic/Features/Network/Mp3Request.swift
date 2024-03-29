//
//  Mp3.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 05.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

struct Mp3Request: RequestType {
    typealias ResponseType = Mp3Response
    let trackId: String
    let albumId: String

    var data: RequestData {
        return RequestData(
            path: String(format: Constants.Track.mp3, trackId, albumId),
            method: .get
        )
    }
}

struct Mp3Response: Decodable {
    let codec: String
    let bitrate: Int
    let src: String
    let gain: Bool
    let preview: Bool
}
