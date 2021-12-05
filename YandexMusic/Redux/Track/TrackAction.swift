//
//  TrackAction.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 28.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

enum TrackAction: AppAction {
    case fetch(type: String, tag: String, queue: [Track], resetCurrent: Bool)
    case update(TrackResponse)
    case togglePlay
    case toggleLike
    case playNext
    case fetchFile
    case updateUrl(URL)
    case playMusic
    case feedbackStationStartUpdate(type: String, tag: String)

    case updateCurrent(Double)
    case updateTotal(Double)
}
