//
//  Track.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

struct TrackState {
    var current: Track?
    var next: Track?
    var isPlaying: Bool = false
    var lastTag: String = ""
    var lastType: String = ""
}

struct Track {
    let id: String
    let name: String
    let album: Album
    let artist: Artist
    let liked: Bool
    var url: URL?

    var fullName: String {
        return [artist.name, name].joined(separator: " - ")
    }

    init(model: TrackDTO) {
        self.id = model.track.id
        self.name = model.track.title
        self.liked = model.liked
        if let first = model.track.albums.first {
            self.album = Album(
                name: first.title,
                id: String(first.id),
                image: URL(string: link(from: first.coverUri))
            )
        }
        else {
            self.album = Album(name: "", id: "", image: nil)
        }
        if let artist = model.track.artists.first {
            self.artist = Artist(name: artist.name, id: String(artist.id))
        }
        else {
            self.artist = Artist(name: "", id: "")
        }
        url = nil
    }
}

struct Album {
    let name: String
    let id: String
    let image: URL?
}

struct Artist {
    let name: String
    let id: String
}
