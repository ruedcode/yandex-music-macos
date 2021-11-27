//
//  CollectionDTO.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

struct CollectionDTO: Decodable {
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
            let children: [ItemDTO]
            let showInMenu: Bool?
        }
    }

    struct ItemDTO: Decodable {
        let name: String
        let children: [ItemDTO]?
        let icon: IconDTO

        struct IconDTO: Decodable {
            let backgroundColor: String
            let imageUrl: String
        }
    }
}


struct FetchCollection: RequestType {
    typealias ResponseType = CollectionDTO

    var data: RequestData {
        return RequestData(
            path: Constants.Collection.url,
            method: .get,
            headers: ["Authorization": "AQAAAAAAV2EkAAeHMAywIeUVtEbJuUw40k6cDd8"]
        )
    }
}


