//
//  Application.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 05.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Cocoa

@objc(MediaApplication)
class MediaApplication: NSApplication {
    
    override func sendEvent(_ event: NSEvent) {
        if (event.type == .systemDefined && event.subtype.rawValue == 8) {
            let keyCode = ((event.data1 & 0xFFFF0000) >> 16)
            let keyFlags = (event.data1 & 0x0000FFFF)
            // Get the key state. 0xA is KeyDown, OxB is KeyUp
            let keyState = (((keyFlags & 0xFF00) >> 8)) == 0xA
            let keyRepeat = (keyFlags & 0x1)

            mediaKeyEvent(key: Int32(keyCode), state: keyState, keyRepeat: keyRepeat != 0)
        }
        super.sendEvent(event)
    }
    func mediaKeyEvent(key: Int32, state: Bool, keyRepeat: Bool) {
        guard let delegate = delegate as? AppDelegate,
              delegate.authProvider.isAuth,
              !delegate.popover.isShown
        else {
            return
        }
        // Only send events on KeyDown. Without this check, these events will happen twice
        if (state) {
            switch(key) {
            case NX_KEYTYPE_PLAY:
                delegate.store.send(
                    delegate.store.state.track.isPlaying
                    ? TrackAction.pause
                    : TrackAction.play
                )
//            case NX_KEYTYPE_FAST:
//                delegate.store.send(
//                    delegate.store.state.track.isPlaying
//                    ? TrackAction.playNext
//                    : TrackAction.play
//                )
            case NX_KEYTYPE_REWIND:
                print("Prev")
                break
            default:
                break
            }
        }
    }
}
