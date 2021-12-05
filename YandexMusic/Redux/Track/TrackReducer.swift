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
    action: AppAction
) -> AnyPublisher<AppAction, Never>? {
    switch action {
    case let TrackAction.fetch(type, tag, queue):
        state.lastTag = tag
        state.lastType = type
        let queue = queue.compactMap { item -> (String, String)? in
            return (item.album.id, item.id)
        }

        return TrackRequest(type: type, tag: tag, queue: queue).execute()
            .map {
                TrackAction.update($0)
            }
            .ignoreError()
            .eraseToAnyPublisher()
    case let TrackAction.update(response):
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

    case TrackAction.togglePlay:
        state.isPlaying = !state.isPlaying
        if state.isPlaying == true {
            if state.current?.url == nil {
                return TrackAction.fetchFile.next
            }
            else {
                return TrackAction.playMusic.next
            }
        }
        else {
            AudioProvider.instance.pause()
        }

    case let TrackAction.updateUrl(url):
        state.current?.url = url
        return TrackAction.playMusic.next

    case TrackAction.fetchFile:
        guard
            let trackId = state.current?.id,
            let albumId = state.current?.album.id
        else {
            return TrackAction.playMusic.next // TODO - error screen
        }

        return TrackService(trackId: trackId, albumId: albumId)
            .fetchUrl()
            .ignoreError()
            .map {
                TrackAction.updateUrl($0)
            }
            .eraseToAnyPublisher()

    case TrackAction.playMusic:
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
                let album = delegate.store.state.track.current?.album.id,
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
    case TrackAction.playNext:
        state.current = state.next
        state.next = nil

        return TrackAction.fetchFile.next
//    case let TrackAction.sendFeedback(type, tag, trackId, albumId):
////        TrackFeedbackRequest(
////            type: type,
////            tag: tag,
////            trackId: trackId,
////            albumId: albumId
//        ).execute(onComplete: { _ in})
    default: break

    }
    return nil
}

