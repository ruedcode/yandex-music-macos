//
//  TrackMiddleware.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 10.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Combine

var trackMiddleware: Middleware<AppState, AppAction> = { store, action in
    switch action {
    case let TrackAction.sendFeedback(event):
        sendFeedback(
            state: store.state.track,
            action: event,
            in: &store.effectCancellables
        )

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
            .ignoreError()
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
        if let item = AudioProvider.instance.player?.currentItem {
            let current = item.currentTime().seconds.asInt
            let duration = item.duration.seconds.asInt
            if current != duration {
                sendFeedback(
                    state: store.state.track,
                    action: .skip,
                    in: &store.effectCancellables
                )
            }
        }

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
        .ignoreError()
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

    TrackFeedbackRequest2(
        params: TrackFeedbackRequest2.Params(
            trackId: track.id,
            albumId: track.album.id,
            nextTrackId: state.next?.id ?? "",
            nextAlbumId: state.next?.album.id ?? "",
            type: state.lastType,
            tag: state.lastTag,
            reason: reason,
            totalPlayed: totalPlayed ?? 0,
            duration: AudioProvider.instance.player?.currentItem?.duration.seconds ?? 0,
            action: act
        )
    )
        .execute()
        .ignoreError()
        .sink { _ in }
        .store(in: &cancellable)


}
