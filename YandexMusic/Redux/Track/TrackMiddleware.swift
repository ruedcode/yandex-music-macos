//
//  TrackMiddleware.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 10.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Combine
import CoreGraphics

var trackMiddleware: Middleware<AppState, AppAction> = { store, action in

    let sendError: (Error) -> Void = {
        Analytics.shared.log(error: $0)
        store.send(TrackAction.error(action, $0))
    }
    switch action {

    case let TrackAction.fetch(type, tag, queue, andPlay):
        guard store.state.track.loadingState != .loading else {
            return
        }
        store.send(TrackAction.startLoading)
        if store.state.track.lastType != type || store.state.track.lastTag != tag {
            store.send(TrackAction.clear)
        }
        let queue = queue.compactMap { item -> (String, String)? in
            return (item.album.id, item.id)
        }
        return TrackRequest(type: type, tag: tag, queue: queue).execute()
            .ignoreError(sendError)
            .sink { response in
                response.tracks.enumerated().forEach { item in
                    guard let albumId = item.element.track.albums.first?.id else {
                        return
                    }
                    TrackService(trackId: item.element.track.id, albumId: String(albumId))
                        .fetchUrl()
                        .ignoreError(sendError)
                        .sink {
                            store.send(TrackAction.add(Track(model: item.element, url: $0)))
                            if andPlay, item.offset == 0 {
                                store.send(TrackAction.play)
                            }
                            // если не удалось набрать композиций, то запрашиваем еще
                            if item.offset == response.tracks.count - 1, store.state.track.items.count <= 1 {
                                store.send(
                                    TrackAction.fetch(
                                        type: type,
                                        tag: tag,
                                        queue: store.state.track.items,
                                        andPlay: store.state.track.isPlaying
                                    )
                                )
                            }
                            store.send(TrackAction.stopLoading)
                        }
                        .store(in: &store.effectCancellables)
                }
            }
            .store(in: &store.effectCancellables)

    case let TrackAction.sendFeedback(event):
        sendFeedback(
            state: store.state.track,
            action: event,
            in: &store.effectCancellables
        )

    case TrackAction.ban:
        guard let track = store.state.track.current else {
            return
        }
        let params = BanRequest.Params(
            trackId: track.id,
            albumId: track.album.id
        )
        return BanRequest(params: params).execute()
            .ignoreError(sendError)
            .sink {
                guard $0.success else {
                    return
                }
                store.send(TrackAction.playNext)
            }
            .store(in: &store.effectCancellables)

    case TrackAction.toggleLike:
        guard let track = store.state.track.current else {
            return
        }
        let params = LikeRequest.Params(
            trackId: track.id,
            albumId: track.album.id,
            like: !track.liked
        )
        return LikeRequest(params: params).execute()
            .ignoreError(sendError)
            .sink {
                guard $0.success else {
                    return
                }
                let isLiked = $0.act != "remove"
                sendFeedback(
                    state: store.state.track,
                    action: isLiked ? .unlike : .like,
                    in: &store.effectCancellables
                )
                store.send(
                    TrackAction.updateLike(
                        trackId: params.trackId,
                        albumId: params.albumId,
                        state: isLiked
                    )
                )
            }
            .store(in: &store.effectCancellables)

    case TrackAction.playNext:
        guard let item = AudioProvider.instance.player?.currentItem else {
            return
        }
        let current = item.currentTime().seconds.asInt
        let duration = item.duration.seconds.asInt
        if current != duration {
            sendFeedback(
                state: store.state.track,
                action: .skip,
                in: &store.effectCancellables
            )
        }
        if store.state.track.items.count <= 3 {
            store.send(
                TrackAction.fetch(
                    type: store.state.track.lastType,
                    tag: store.state.track.lastTag,
                    queue: store.state.track.items,
                    andPlay: store.state.track.isPlaying
                )
            )
        }
    case let TrackAction.seek(value):
        guard let player = AudioProvider.instance.player,
              let duration = player.currentItem?.duration.seconds.asInt
        else {
            return
        }
        let seconds = CGFloat(duration) * value
        guard seconds >= 0, seconds <= CGFloat(duration) else {
            return
        }
        AudioProvider.instance.seek(to: seconds)

    default:
        break
    }
}

private func sendFeedback(
    state: TrackState,
    action: TrackFeedbackRequest.Action,
    in cancellable: inout Set<AnyCancellable>
) {
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
    )
        .execute()
        .ignoreError(analytics: true)
        .sink { _ in }
        .store(in: &cancellable)

    let reason: TrackFeedbackRequest2.Reason?
    let act: TrackFeedbackRequest2.Action?

    switch action {
    case .skip:
        reason = .skip
        act = .end
    case .trackStarted:
        reason = .trackStarted
        act = .start
    case .trackFinished:
        reason = .end
        act = .end
    default:
        reason = nil
        act = nil

    }
    guard let reason = reason, let act = act else {
        return
    }
    let nextTrack = state.items.first

    TrackFeedbackRequest2(
        params: TrackFeedbackRequest2.Params(
            trackId: track.id,
            albumId: track.album.id,
            nextTrackId: nextTrack?.id ?? "",
            nextAlbumId: nextTrack?.album.id ?? "",
            type: state.lastType,
            tag: state.lastTag,
            reason: reason,
            totalPlayed: totalPlayed ?? 0,
            duration: AudioProvider.instance.player?.currentItem?.duration.seconds ?? 0,
            action: act
        )
    )
        .execute()
        .ignoreError(analytics: true)
        .sink { _ in }
        .store(in: &cancellable)
}
