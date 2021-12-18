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
    case TrackAction.error:
        state.error = ErrorState(action: TrackAction.playNext)
        if state.isPlaying {
            return TrackAction.pause.next
        }

    case let TrackAction.fetch(type, tag, _, _):
        state.lastTag = tag
        state.lastType = type

    case let TrackAction.add(track):
        state.items.append(track)

    case TrackAction.clear:
        state.items = []

    case TrackAction.play:
        guard let track = state.current else {
            return nil
        }
        state.isPlaying = true
        AudioProvider.instance.play(track: track)

        AudioProvider.instance.onFinish = {
            guard let delegate = NSApp.delegate as? AppDelegate else { return }
            delegate.store.send(TrackAction.sendFeedback(.trackFinished))
            delegate.store.send(TrackAction.playNext)
        }
        AudioProvider.instance.onError = {
            guard let delegate = NSApp.delegate as? AppDelegate else { return }
            delegate.store.send(TrackAction.sendFeedback(.skip))
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

    case TrackAction.pause:
        state.isPlaying = false
        AudioProvider.instance.pause()


    case TrackAction.resetPlayer:
        AudioProvider.instance.reset()
        
    case TrackAction.playNext:
        state.items = Array(state.items.dropFirst())
        guard state.items.first != nil else {
            return TrackAction.fetch(
                type: state.lastType,
                tag: state.lastTag,
                queue: [],
                andPlay: true
            ).next
        }
        return TrackAction.play.next

    case let TrackAction.feedbackStationStartUpdate(type, tag):
        state.feedback.lastStation = tag + type

    case let TrackAction.updateTotal(time):
        state.totalTime = time

    case let TrackAction.updateCurrent(time):
        state.currentTime = time

    case let TrackAction.updateLike(trackId, albumId, val):
        guard let index = state.items.firstIndex(where: {
            $0.id == trackId && $0.album.id == albumId
        }) else {
            return nil

        }
        state.items[index].liked = val

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
