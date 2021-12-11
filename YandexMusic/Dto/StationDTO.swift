//
//  StationDTO.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

struct GroupDTO: Decodable {
    let id: String
    let name: String?
    let children: [StationDTO]
    let showInMenu: Bool?
}

struct StationDTO: Decodable {
    let name: String
    let children: [StationDTO]?
    let icon: IconDTO
    let idForFrom: String
    let id: StationIdDTO

    struct IconDTO: Decodable {
        let backgroundColor: String
        let imageUrl: String
    }
}

struct StationIdDTO: Decodable {
    let type: String
    let tag: String
}
