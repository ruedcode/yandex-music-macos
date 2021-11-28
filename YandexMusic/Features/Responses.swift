//
//  Responses.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 28.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

struct RecomendationResponse: Decodable {
    let stations: [ItemDTO]

    struct ItemDTO: Decodable {
        let station: StationDTO
    }
}

struct LibraryResponse: Decodable {
    let types: GroupsDTO?
}

struct TrackResponse: Decodable {
    let tracks: [TrackDTO]
}

