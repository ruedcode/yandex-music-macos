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
            return TrackAction.fetch(
                type: state.lastType,
                tag: state.lastTag,
                queue: [],
                andPlay: true
            )
            .next
        }
        state.isPlaying = true
        AudioProvider.instance.play(track: track)
        Analytics.shared.log(event: .play, params: track.analytics)

    case TrackAction.pause:
        state.isPlaying = false
        AudioProvider.instance.pause()
        Analytics.shared.log(event: .play, params: state.current?.analytics)

    case TrackAction.resetPlayer:
        AudioProvider.instance.reset()
        
    case TrackAction.playNext:
        var params = state.current?.analytics
        state.items = Array(state.items.dropFirst())
        guard state.items.first != nil else {
            return TrackAction.fetch(
                type: state.lastType,
                tag: state.lastTag,
                queue: [],
                andPlay: true
            ).next
        }
        params?["next"] = state.current?.analytics ?? [:]
        Analytics.shared.log(
            event: .next,
            params: params
        )
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
        var params = state.items[index].analytics
        params["new_like_value"] = val
        state.items[index].liked = val
        Analytics.shared.log(event: val ? .like : .unlike, params: params)

    case TrackAction.share:
        guard let track = state.current else {
            return nil
        }

        let string = String(format: Constants.Track.share, track.album.id, track.id)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(string, forType: .URL)
        var params = track.analytics
        params["link"] = string
        Analytics.shared.log(
            event: .share,
            params: params
        )

    default: break

    }
    return nil
}
