//
//  SectionAction.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

enum StationAction: AppAction {
    case fetch
    case update([StationDTO])
    case select(Station, andPlay: Bool, isPlaying: Bool)
}
