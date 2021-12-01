//
//  TrackReducer.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 28.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation
import Combine
import Cocoa

func trackReducer(
    state: inout TrackState,
    action: TrackAction
) -> AnyPublisher<AppAction, Never> {
    switch action {
    case let .fetch(type, tag, queue):
        state.lastTag = tag
        state.lastType = type
        let queue = queue.compactMap { item -> (String, String)? in
            if let albumId = item.album?.id {
                return (albumId, item.id)
            }
            else {
                return nil
            }
        }

        return TrackRequest(type: type, tag: tag, queue: queue).execute()
            .map {
                TrackAction.update($0)
            }
            .ignoreError()
            .eraseToAnyPublisher()
    case let .update(response):
        if let current = response.tracks.first {
            if state.current == nil {
                state.current = Track(model: current)
                if let next = response.tracks.suffix(1).first {
                    state.next = Track(model: next)
                }
            }
            else {
                state.next = Track(model: current)
            }
        }

    case .togglePlay:
        state.isPlaying = !state.isPlaying
        if state.isPlaying == true {
            if state.current?.url == nil {
                return TrackAction.fetchStorageHost.next
            }
            else {
                return TrackAction.playMusic.next
            }
        }
        else {
            AudioProvider.instance.pause()
        }
    case .fetchStorageHost:
        if
            state.current?.url == nil,
            let trackId = state.current?.id,
            let albumId = state.current?.album?.id
        {
            return Mp3Request(trackId: trackId, albumId: albumId).execute().map {
                TrackAction.fetchFileInfo("https:\($0.src)")
            }
            .ignoreError()
            .eraseToAnyPublisher()
        }
        else {
            return TrackAction.playMusic.next
        }
    case let .fetchFileInfo(path):
        return FileRequest(path: path).execute()
            .map {
                TrackAction.updateUrl($0)
            }.ignoreError()
            .eraseToAnyPublisher()
    case let .updateUrl(response):
        let path = "https://\(response.host)/get-mp3/falfn2o3finf023nn02nd0120192n012/\(response.ts)\(response.path)"
        if let url = URL(string: path) {
            state.current?.url = url
            return TrackAction.playMusic.next
        }
    case .playMusic:
        guard let track = state.current, let url = track.url else {
            return TrackAction.fetch(type: state.lastType, tag: state.lastTag, queue: []).next
        }
        AudioProvider.instance.play(url: url)
        AudioProvider.instance.onFinish = {
            if let delegate = NSApp.delegate as? AppDelegate {
                delegate.store.send(TrackAction.playNext)
            }
        }
        AudioProvider.instance.onStart = {
            if
                let delegate = NSApp.delegate as? AppDelegate,
                let station = delegate.store.state.collection.selected,
                let album = delegate.store.state.track.current?.album?.id,
                let track = delegate.store.state.track.current?.id
            {
                delegate.store.send(
                    TrackAction.sendFeedback(
                        type: station.type,
                        tag: station.tag,
                        trackId: track,
                        albumId: album
                    )
                )
            }
        }
        if state.next == nil {
            return TrackAction.fetch(
                type: state.lastType,
                tag: state.lastTag,
                queue: [track]
            ).next
        }
    case .playNext:
        state.current = state.next
        state.next = nil

        return TrackAction.fetchStorageHost.next
    case let .sendFeedback(type, tag, trackId, albumId):
        TrackFeedbackRequest(
            type: type,
            tag: tag,
            trackId: trackId,
            albumId: albumId
        ).execute(onComplete: { _ in})

    }
    return Empty().eraseToAnyPublisher()
}

