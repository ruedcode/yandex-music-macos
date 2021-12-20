//
//  Track.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

struct TrackState {
    var items: [Track] = []
    var isPlaying: Bool = false
    var lastTag: String = ""
    var lastType: String = ""
    var feedback: TrackFeedback = TrackFeedback()
    var currentTime: Double = 0
    var totalTime: Double = 0
    var error: ErrorState?

    var current: Track? {
        items.first
    }

    var next: Track? {
        items.suffix(1).first
    }
}

struct TrackFeedback {
    var lastStation: String?
    var lastTrack: String?
}

struct Track {
    let id: String
    let name: String
    let album: Album
    let artist: Artist
    var liked: Bool
    var url: URL
    let batchId: String

    var fullName: String {
        return [artist.name, name].joined(separator: " - ")
    }

    init(model: TrackDTO, url: URL) {
        self.id = model.track.id
        self.name = model.track.title
        self.liked = model.liked
        self.batchId = model.track.batchId
        if let first = model.track.albums.first {
            self.album = Album(
                name: first.title,
                id: String(first.id),
                image: URL(string: link(from: first.coverUri ?? ""))
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

        self.url = url
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
