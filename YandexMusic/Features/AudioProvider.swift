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

//    private var audioFile: AVAudioFile?
//    private var audioEngine: AVAudioEngine
//    private var playerNode: AVAudioPlayerNode

//    init() {
//        audioEngine = AVAudioEngine()
//        playerNode = AVAudioPlayerNode()
//        audioEngine.attach(playerNode)
//    }

//    func play(url: URL? = nil) {
//        let file: AVAudioFile
//        if let url = url, let tmp = try? AVAudioFile(forReading: url) {
//            file = tmp
//        }
//        else if url == nil, let tmp = audioFile {
//            file = tmp
//        }
//        else {
//            return
//        }
//
//        audioFile = file
//
//        audioEngine.connect(
//            playerNode,
//            to: audioEngine.outputNode,
//            format: file.processingFormat
//        )
//        playerNode.scheduleFile(
//            file,
//            at: nil,
//            completionCallbackType: .dataPlayedBack
//        ) { _ in
//            print("www")
//        }
//        do {
//            try audioEngine.start()
//            playerNode.play()
//        } catch {
//            print("error \(error)")
//        }
//    }
//
//    func pause() {
//        playerNode.stop()
//        audioEngine.stop()
//    }

    private var player: AVPlayer?

    func play(url: URL? = nil) {
        if let url = url {
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
