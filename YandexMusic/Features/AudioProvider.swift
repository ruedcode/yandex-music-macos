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

    private var player: AVPlayer?
    private var lastURL: URL?
    private var observer: NSKeyValueObservation?

    var onFinish: () -> Void = {}
    var onStart: () -> Void = {}

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
            player?.rate = 1
            observer = playerItem.observe(
                \.status,
                 options: [.new],
                 changeHandler: { [weak self] player, values in
                     if player.status == .readyToPlay {
                         self?.onStart()
                     }
            })
        }

        player?.play()
    }

    func pause() {
        player?.pause()
    }

    @objc private func playerDidFinishPlaying(sender: Notification) {
        onFinish()
    }
}
