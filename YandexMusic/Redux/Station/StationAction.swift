//
//  SectionAction.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

enum StationAction: AppAction {
    case fetch
    case update([GroupDTO])
    case select(Station, andPlay: Bool)
    case selectGroup(StationGroup, andPlay: Bool)
    case error(AppAction, Error)
    case reload
}
