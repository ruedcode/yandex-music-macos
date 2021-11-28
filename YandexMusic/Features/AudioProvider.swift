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

    func play(url: URL? = nil) {
        if let url = url, lastURL != url {
            lastURL = url
            let playerItem = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: playerItem)
            player?.rate = 1
        }
        player?.play()
    }

    func pause() {
        player?.pause()
    }
}
