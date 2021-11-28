//
//  TrackAction.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 28.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

enum TrackAction: AppAction {
    case fetch(type: String, tag: String, queue: [TrackDTO])
    case update(TrackResponse)
    case tooglePlay
    case fetchStorageHost
    case fetchFileInfo(String)
    case updateUrl(FileResponse)
    case playMusic
}
