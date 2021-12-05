//
//  CollectionAction.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

enum CollectionAction: AppAction {
    case fetch
    case update(RecomendationResponse)
    case select(Station, andPlay: Bool)
}
