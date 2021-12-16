//
//  AudioProvider.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 28.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import SwiftUI
import Foundation
import MediaPlayer
import AVFoundation

final class AudioProvider {
    static let instance = AudioProvider()

    private let volumeDefaultsKey = "music_volume"

    private(set) var player: AVPlayer?
    private var lastURL: URL?
    private var observer: NSKeyValueObservation?
    private var nowPlayingInfo: [String: Any] = [:] {
        didSet { MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo }
    }

    var onFinish: () -> Void = {}
    var onStart: (Double) -> Void = {_ in }
    var onCurrentUpdate: (Double) -> Void = {_ in}

    @Stored(for: .musicVolume, defaultValue: 1.0)
    var volume: Float {
        didSet { player?.volume = volume }
    }

    deinit {
        reset()
    }

    func connect(to store: Store<AppState, AppAction>) {
        MPRemoteCommandCenter.shared().playCommand.addTarget { [weak store] _ in
            store?.send(TrackAction.play)
            return .success
        }
        MPRemoteCommandCenter.shared().pauseCommand.addTarget { [weak store] _ in
            store?.send(TrackAction.pause)
            return .success
        }
        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget { [weak store] _ in
            store?.send(TrackAction.playNext)
            return .success
        }
        MPRemoteCommandCenter.shared().changePlaybackPositionCommand.isEnabled = false
        MPRemoteCommandCenter.shared().changePlaybackPositionCommand.addTarget { [weak self] _ in
            self?.set(state: .interrupted)
            self?.set(state: .playing)
            return .noActionableNowPlayingItem
        }
    }

    func play(track: Track) {
        if lastURL != track.url {
            lastURL = track.url
            let playerItem = AVPlayerItem(url: track.url)
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.playerDidFinishPlaying(sender:)),
                name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                object: nil
            )
            player = AVPlayer(playerItem: playerItem)
            player?.volume = volume
            player?.rate = 1
            observer = playerItem.observe(
                \.status,
                 options: [.new],
                 changeHandler: { [weak self] player, values in
                     guard player.status == .readyToPlay else { return }
                     self?.set(track: track)
                     self?.set(duration: player.duration.seconds)
                     self?.set(state: .playing)
                     self?.onStart(player.duration.seconds)
            })

            player?.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 2), queue: nil, using: { [weak self] time in
                self?.set(currentTime: time.seconds)
                self?.onCurrentUpdate(time.seconds)
            })
        }
        else {
            set(state: .playing)
        }

        player?.play()
    }

    func pause() {
        player?.pause()
        set(state: .paused)
    }

    func reset() {
        player?.pause()
        set(state: .paused)
        NotificationCenter.default.removeObserver(self)
        MPNowPlayingInfoCenter.default().playbackState = .unknown
        nowPlayingInfo.removeAll()
        player = nil
    }

    @objc private func playerDidFinishPlaying(sender: Notification) {
        set(state: .stopped)
        onFinish()
    }

    // MARK: - MediaPlayer block

    private func set(currentTime: Double) {
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
    }

    private func set(duration: Double) {
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
    }

    private func set(track: Track) {
        nowPlayingInfo[MPMediaItemPropertyTitle] = track.name
        nowPlayingInfo[MPMediaItemPropertyArtist] = track.artist.name
        if let url = track.album.image {
            URLSession.shared.dataTask(with: url, completionHandler: { [weak self] (data, _, _) in
                if let data = data, let image = NSImage(data: data) {
                    let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in
                        image
                    }
                    self?.nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
                }
            }).resume()
        }
    }

    private func set(state: MPNowPlayingPlaybackState) {
        MPNowPlayingInfoCenter.default().playbackState = state
    }
}
