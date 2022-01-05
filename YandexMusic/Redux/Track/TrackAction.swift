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
    case startLoading
    case stopLoading
    case add(Track)
    case clear
    case play
    case pause
    case toggleLike
    case updateLike(trackId: String, albumId: String, state: Bool)
    case playNext
    case sendFeedback(TrackFeedbackRequest.Action)
    case resetPlayer
    case feedbackStationStartUpdate(type: String, tag: String)
    case share
    case ban
    case error(AppAction, Error)

    case updateCurrent(Double)
    case updateTotal(Double)
}
