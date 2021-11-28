//
//  CollectionDTO.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

struct LibraryDTO: Decodable {
    let types: GroupsDTO?

    struct GroupsDTO: Decodable {
        let user: GroupDTO
        let genre: GroupDTO
        let mood: GroupDTO
        let activity: GroupDTO
        let epoch: GroupDTO
        let author: GroupDTO

        struct GroupDTO: Decodable {
            let id: String
            let name: String?
            let children: [StationDTO]
            let showInMenu: Bool?
        }
    }
}

struct StationDTO: Decodable {
    let name: String
    let children: [StationDTO]?
    let icon: IconDTO
    let idForFrom: String

    struct IconDTO: Decodable {
        let backgroundColor: String
        let imageUrl: String
    }
}

struct RecomendationDTO: Decodable {
    let stations: [ItemDTO]

    struct ItemDTO: Decodable {
        let station: StationDTO
    }
}

struct FetchLibrary: RequestType {
    typealias ResponseType = LibraryDTO

    var data: RequestData {
        return RequestData(
            path: Constants.Collection.library,
            method: .get,
            auth: true
        )
    }
}

struct FetchRecommendation: RequestType {
    typealias ResponseType = RecomendationDTO

    var data: RequestData {
        return RequestData(
            path: Constants.Collection.recommendation,
            method: .get,
            auth: true
        )
    }
}


