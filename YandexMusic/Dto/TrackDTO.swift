//
//  TrackDTO.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 28.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

struct TrackDTO: Decodable {
    let type: String
    let liked: Bool
    let track: TrackInfoDTO
}

struct TrackInfoDTO: Decodable {
    let albums: [AlbumDTO]
    let artists: [ArtistDTO]
    let coverUri: String
    let batchId: String
    let id: String
    let storageDir: String
    let title: String
}

struct AlbumDTO: Decodable {
    let coverUri: String?
    let genre: String?
    let id: Int
    let likesCount: Int?
    let title: String
}

struct ArtistDTO: Decodable {
    let name: String
    let id: Int
}
