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
    case let TrackAction.fetch(type, tag, queue, andPlay):
        if andPlay {
            state.current = nil
        }
        state.lastTag = tag
        state.lastType = type
        let queue = queue.compactMap { item -> (String, String)? in
            return (item.album.id, item.id)
        }

        return TrackRequest(type: type, tag: tag, queue: queue).execute()
            .map {
                TrackAction.update($0, andPlay: andPlay)
            }
            .ignoreError()
            .eraseToAnyPublisher()
    case let TrackAction.update(response, andPlay):
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
        if andPlay {
            state.isPlaying = !state.isPlaying
            if state.current?.url == nil {
                return TrackAction.fetchFile.next
            }
            else {
                return TrackAction.runPlayer.next
            }
        }
    case TrackAction.play:
        state.isPlaying = true
        if state.current?.url == nil {
            return TrackAction.fetchFile.next
        }
        else {
            return TrackAction.runPlayer.next
        }

    case TrackAction.pause:
        state.isPlaying = false
        AudioProvider.instance.pause()

    case let TrackAction.updateUrl(url):
        state.current?.url = url
        return TrackAction.runPlayer.next

    case TrackAction.fetchFile:
        guard
            let trackId = state.current?.id,
            let albumId = state.current?.album.id
        else {
            return TrackAction.runPlayer.next // TODO - error screen
        }

        return TrackService(trackId: trackId, albumId: albumId)
            .fetchUrl()
            .ignoreError()
            .map {
                TrackAction.updateUrl($0)
            }
            .eraseToAnyPublisher()

    case TrackAction.runPlayer:
        guard let track = state.current, let url = track.url else {
            return TrackAction.fetch(
                type: state.lastType,
                tag: state.lastTag,
                queue: [],
                andPlay: true
            ).next
        }
        AudioProvider.instance.play(url: url)
        AudioProvider.instance.onFinish = {
            if let delegate = NSApp.delegate as? AppDelegate {
                sendFeedback(state: delegate.store.state.track, action: .trackFinished)
                delegate.store.send(TrackAction.playNext)
            }
        }
        AudioProvider.instance.onStart = { time in
            if let delegate = NSApp.delegate as? AppDelegate {
                delegate.store.send(TrackAction.updateTotal(time))
                sendFeedback(state: delegate.store.state.track, action: .radioStarted)
                delegate.store.send(
                    TrackAction.feedbackStationStartUpdate(
                        type: delegate.store.state.track.lastType,
                        tag: delegate.store.state.track.lastTag
                    )
                )
                sendFeedback(state: delegate.store.state.track, action: .trackStarted)
            }
        }
        AudioProvider.instance.onCurrentUpdate = { time in
            if let delegate = NSApp.delegate as? AppDelegate {
                delegate.store.send(TrackAction.updateCurrent(time))
            }
        }
        if state.next == nil {
            return TrackAction.fetch(
                type: state.lastType,
                tag: state.lastTag,
                queue: [track],
                andPlay: false
            ).next
        }
        
    case TrackAction.playNext:
        if let item = AudioProvider.instance.player?.currentItem {
            let current = Int(item.currentTime().seconds)
            let duration = Int(item.duration.seconds)
            print("curr \(current) \(duration)")
            if current != duration {
                sendFeedback(state: state, action: .skip)
            }
        }
        state.current = state.next
        state.next = nil

        return TrackAction.fetchFile.next
    case let TrackAction.feedbackStationStartUpdate(type, tag):
        state.feedback.lastStation = tag + type

    case let TrackAction.updateTotal(time):
        state.totalTime = time

    case let TrackAction.updateCurrent(time):
        state.currentTime = time

    case TrackAction.toggleLike:
        guard let track = state.current else {
            return nil
        }
        state.current?.liked = !track.liked
        sendFeedback(state: state, action: track.liked ? .unlike : .like)
        let params = LikeRequest.Params(
            trackId: track.id,
            albumId: track.album.id,
            like: !track.liked
        )
        return LikeRequest(params: params).execute()
            .ignoreError()
            .map {
                TrackAction.updateLike(
                    trackId: params.trackId,
                    albumId: params.albumId,
                    state: $0.success && $0.act != "remove"
                )
            }
            .eraseToAnyPublisher()
    case let TrackAction.updateLike(trackId, albumId, val):
        guard state.current?.id == trackId, state.current?.album.id == albumId else {
            return nil
        }
        state.current?.liked = val

    default: break

    }
    return nil
}

private func sendFeedback(state: TrackState, action: TrackFeedbackRequest.Action) {
    guard let track = state.current else {
        return
    }
    if action == .radioStarted, state.feedback.lastStation == state.lastTag + state.lastType {
        return
    }
    let batchId = action == .radioStarted ? nil : track.batchId
    let totalPlayed = action == .radioStarted ? nil : AudioProvider.instance.player?.currentTime().seconds

    TrackFeedbackRequest(
        params: TrackFeedbackRequest.Params(
            type: state.lastType,
            tag: state.lastTag,
            trackId: track.id,
            albumId: track.album.id,
            action: action,
            batchId: batchId,
            totalPlayed: totalPlayed
        )
    ).execute(onComplete: {_ in})

}

