//
//  NowPlayingProvider.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 07.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import MediaPlayer
import SwiftUI
import Cocoa

final class NowPlayingProvider {
    static let instance = NowPlayingProvider()

    private var nowPlayingInfo: [String: Any] = [:]

    var onPause: () -> Void = {}
    var onPlay: () -> Void = {}
    var onNext: () -> Void = {}

    init() {
        MPRemoteCommandCenter.shared().playCommand.addTarget { [weak self] _ in
            self?.onPlay()
            return .success
        }
        MPRemoteCommandCenter.shared().pauseCommand.addTarget { [weak self] _ in
            self?.onPause()
            return .success
        }
        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget { [weak self] _ in
            self?.onNext()
            return .success
        }
        MPRemoteCommandCenter.shared().changePlaybackPositionCommand.isEnabled = false
        MPRemoteCommandCenter.shared().changePlaybackPositionCommand.addTarget(handler: { [weak self] _ in
            self?.set(state: .interrupted)
            self?.set(state: .playing)
            return .noActionableNowPlayingItem
        })
    }

    func set(currentTime: Double) {
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        notify()
    }

    func set(duration: Double) {
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        notify()
    }

    func set(track: Track) {
        nowPlayingInfo[MPMediaItemPropertyTitle] = track.name
        nowPlayingInfo[MPMediaItemPropertyArtist] = track.artist.name
        notify()
        if let url = track.album.image {
            URLSession.shared.dataTask(with: url, completionHandler: { [weak self] (data, _, _) in
                if let data = data, let image = NSImage(data: data) {
                    let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in
                        image
                    }
                    self?.nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
                    self?.notify()
                }
            }).resume()
        }
    }

    func set(state: MPNowPlayingPlaybackState) {
        MPNowPlayingInfoCenter.default().playbackState = state
    }

    private func notify() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}
