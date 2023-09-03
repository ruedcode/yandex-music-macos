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
            params: .urlenencoded(
                Form(
                    batchId: params.batchId,
                    trackId: params.trackId,
                    albumId: params.albumId,
                    totalPlayed: params.totalPlayed
                )
            )
        )
    }

    enum Action: String {
        case radioStarted
        case trackStarted
        case trackFinished
        case skip
        case like
        case unlike
    }

    struct Params {
        let type: String
        let tag: String
        let trackId: String
        let albumId: String
        let action: Action
        let batchId: String?
        let totalPlayed: Double?
    }

    fileprivate struct Form: Encodable {
        let timestamp: TimeInterval = Date().timeIntervalSince1970
        let from: String = "web-radio-user-saved"
        let sign: String = AuthProviderImpl.instance.profile?.csrf ?? ""
        let overembed: String = "no"
        let batchId: String?
        let trackId: String?
        let albumId: String?
        let totalPlayed: Double?
    }
}

struct TrackFeedbackResponse: Decodable {
    let result: String
    let info: String
}


struct TrackFeedbackRequest2: RequestType {
    typealias ResponseType = TrackFeedbackResponse2

    let params: Params

    struct Params {
        let trackId: String
        let albumId: String
        let nextTrackId: String
        let nextAlbumId: String
        let type: String
        let tag: String
        let reason: Reason
        let totalPlayed: Double
        let duration: Double
        let action: Action
    }

    enum Action: String, Codable {
        case start
        case end
    }

    enum Reason: String, Codable {
        case trackStarted
        case end
        case skip
    }

    fileprivate struct Form: Encodable {
        let timestamp: Int = Int(Date().timeIntervalSince1970)
        let data: [TrackFeedbackRequest2.Data]
        let sign: String = AuthProviderImpl.instance.profile?.csrf ?? ""
        let overembed: String = "no"
    }

    fileprivate struct Data: Encodable {
        let sendReason: Reason
        let from: String = "web-radio-user-saved"
        let restored: Bool = false
        let preview: Bool = false
        let nextTrackId: String
        let yaDisk: Bool = false
        let duration: Double
        let position: Double
        let played: Double
        let playId: String = UUID().uuidString
        let feedback: String
        let context: String = "radio"
        let contextItem: String
        let timestamp: Int
        let trackId: String
        let album: Int
    }

    var data: RequestData {
        return RequestData(
            path: String(
                format: Constants.Track.feedback2,
                params.trackId,
                params.albumId,
                params.reason.rawValue
            ),
            method: .post,
            params: .json(
                Form(
                    data: [
                        Data(
                            sendReason: params.reason,
                            nextTrackId: params.nextTrackId + ":" + params.nextAlbumId,
                            duration: params.duration,
                            position: params.totalPlayed,
                            played: params.totalPlayed,
                            feedback: params.reason.rawValue,
                            contextItem: params.type + ":" + params.tag,
                            timestamp: Int(Date().timeIntervalSince1970),
                            trackId: params.trackId,
                            album: Int(params.albumId) ?? 0
                        )
                    ]
                )
            )
        )
    }

}

struct TrackFeedbackResponse2: Decodable {
    let result: Bool
}
