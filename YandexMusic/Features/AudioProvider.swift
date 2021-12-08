//
//  AudioProvider.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 28.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation
//import AVFAudio
import AVFoundation

final class AudioProvider {
    static let instance = AudioProvider()

    private let volumeDefaultsKey = "music_volume"

    private(set) var player: AVPlayer?
    private var lastURL: URL?
    private var observer: NSKeyValueObservation?

    var onFinish: () -> Void = {}
    var onStart: (Double) -> Void = {_ in }
    var onPause: () -> Void = {}
    var onResume: () -> Void = {}
    var onCurrentUpdate: (Double) -> Void = {_ in}

    var volume: Float {
        get { UserDefaults.standard.object(forKey: volumeDefaultsKey) as? Float ?? 1 }
        set {
            UserDefaults.standard.set(newValue, forKey: volumeDefaultsKey)
            player?.volume = newValue
        }
    }

    func play(url: URL? = nil) {
        if let url = url, lastURL != url {
            lastURL = url
            let playerItem = AVPlayerItem(url: url)
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
                     if player.status == .readyToPlay {
                         self?.onStart(player.duration.seconds)
                     }
            })

            player?.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 2), queue: nil, using: { [weak self] time in
                self?.onCurrentUpdate(time.seconds)
            })
        }
        else {
            onResume()
        }

        player?.play()
    }

    func pause() {
        player?.pause()
        onPause()
    }

    @objc private func playerDidFinishPlaying(sender: Notification) {
        onFinish()
    }
}
