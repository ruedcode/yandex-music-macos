//
//  TrackReducer.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 28.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation
import Combine

func trackReducer(
    state: inout TrackState,
    action: TrackAction,
    store: Store<AppState, AppAction>
) -> AnyPublisher<AppAction, Never> {
    switch action {
    case let .fetch(type, tag, _):
        return TrackRequest(type: type, tag: tag, queue: []).execute()
            .map {
                TrackAction.update($0)
            }
            .catch { error in
                Empty(completeImmediately: true)
            }
            .eraseToAnyPublisher()
    case let .update(response):
        if let current = response.tracks.first {
            state.current = Track(model: current)
        }
        if let next = response.tracks.suffix(1).first {
            state.next = Track(model: next)
        }
    case .tooglePlay:
        state.isPlaying = !state.isPlaying
        if state.isPlaying == true {
            if state.current?.url == nil {
                store.send(TrackAction.fetchStorageHost)
            }
            else {
                store.send(TrackAction.playMusic)
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
            }.catch { error in
                Empty(completeImmediately: true)
            }.eraseToAnyPublisher()
        }
        else {
            store.send(TrackAction.playMusic)
        }
    case let .fetchFileInfo(path):
        return FileRequest(path: path).execute()
            .map {
                TrackAction.updateUrl($0)
            }.catch { error in
                Empty(completeImmediately: true)
            }.eraseToAnyPublisher()
    case let .updateUrl(response):
        let path = "https://\(response.host)/get-mp3/falfn2o3finf023nn02nd0120192n012/\(response.ts)\(response.path)"
        if let url = URL(string: path) {
            state.current?.url = url
            return Future<AppAction, Error>() { promise in
                promise(.success(TrackAction.playMusic))
            }.catch { _ in
                Empty(completeImmediately: true)
            }.eraseToAnyPublisher()
        }
    case .playMusic:
        guard let url = state.current?.url else {
            break
        }
        AudioProvider.instance.play(url: url)
    }
    return Empty().eraseToAnyPublisher()
}

