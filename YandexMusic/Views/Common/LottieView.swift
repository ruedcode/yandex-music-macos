//
//  LottieView.swift
//  YandexMusic
//
//  Created by Mike Price on 21.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import SwiftUI
import Lottie

// TODO: Need performance optimization in play with audio
struct LottieView: NSViewRepresentable {

    var name: String
    var loopMode: LottieLoopMode = .playOnce
    @Binding var isPlaying: Bool

    var animationView = AnimationView()

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)

        animationView.animation = Animation.named(name)
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.isHidden = true

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        guard let animationView = nsView.subviews.first as? AnimationView else {
            return
        }
        if !animationView.isAnimationPlaying && isPlaying {
            animationView.isHidden = false
            animationView.play()
        } else if animationView.isAnimationPlaying && !isPlaying {
            animationView.isHidden = true
            animationView.stop()
        }
    }

}
