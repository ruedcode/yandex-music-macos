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
import UserNotifications

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
        guard let track = state.current, track.url != nil else {
            return TrackAction.fetch(
                type: state.lastType,
                tag: state.lastTag,
                queue: [],
                andPlay: true
            ).next
        }
        state.isPlaying = true
        AudioProvider.instance.play(track: track)

        AudioProvider.instance.onFinish = {
            guard let delegate = NSApp.delegate as? AppDelegate else { return }
            delegate.store.send(TrackAction.sendFeedback(.trackFinished))
            delegate.store.send(TrackAction.playNext)
        }
        AudioProvider.instance.onStart = { time in
            guard let delegate = NSApp.delegate as? AppDelegate else { return }
            delegate.store.send(TrackAction.updateTotal(time))
            delegate.store.send(TrackAction.sendFeedback(.radioStarted))
            delegate.store.send(
                TrackAction.feedbackStationStartUpdate(
                    type: delegate.store.state.track.lastType,
                    tag: delegate.store.state.track.lastTag
                )
            )
            delegate.store.send(TrackAction.sendFeedback(.trackStarted))
        }
        AudioProvider.instance.onCurrentUpdate = { time in
            guard let delegate = NSApp.delegate as? AppDelegate else { return }
            delegate.store.send(TrackAction.updateCurrent(time))
        }
        if state.next == nil {
            return TrackAction.fetch(
                type: state.lastType,
                tag: state.lastTag,
                queue: [track],
                andPlay: false
            ).next
        }

    case TrackAction.resetPlayer:
        AudioProvider.instance.reset()
        
    case TrackAction.playNext:
        state.current = state.next
        state.next = nil

        return TrackAction.fetchFile.next
    case let TrackAction.feedbackStationStartUpdate(type, tag):
        state.feedback.lastStation = tag + type

    case let TrackAction.updateTotal(time):
        state.totalTime = time

    case let TrackAction.updateCurrent(time):
        state.currentTime = time

    case let TrackAction.updateLike(trackId, albumId, val):
        guard state.current?.id == trackId, state.current?.album.id == albumId else {
            return nil
        }
        state.current?.liked = val

    case TrackAction.share:
        guard let track = state.current else {
            return nil
        }

        let string = String(format: Constants.Track.share, track.album.id, track.id)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(string, forType: .URL)

    default: break

    }
    return nil
}
