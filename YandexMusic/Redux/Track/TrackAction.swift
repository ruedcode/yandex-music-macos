//
//  TrackAction.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 28.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

enum TrackAction: AppAction {
    case fetch(type: String, tag: String, queue: [Track], andPlay: Bool)
    case update(TrackResponse, andPlay: Bool)
    case play
    case pause
    case toggleLike
    case updateLike(trackId: String, albumId: String, state: Bool)
    case playNext
    case fetchFile
    case updateUrl(URL)
    case runPlayer
    case sendFeedback(TrackFeedbackRequest.Action)
    case feedbackStationStartUpdate(type: String, tag: String)
    case share

    case updateCurrent(Double)
    case updateTotal(Double)
}
