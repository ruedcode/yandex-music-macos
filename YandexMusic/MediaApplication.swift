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
              delegate.store.state.auth.mode == .authorized
        else {
            return
        }
        // Only send events on KeyDown. Without this check, these events will happen twice
        if (state) {
            switch(key) {
            case NX_KEYTYPE_PLAY:
                /* You can provide logic here. You have the option of calling functions
                 * in your app's NSApplicationDelegate
                 *
                 * Examples:
                 * Call a function named 'printMessage' in the NSApplicationDelegate
                 * delegate!.performSelector("printMessage")
                 * printMessage looks like the following:
                 * func printMessage() {
                 *     print("Hello World")
                 * }
                 *
                 * Call a function named 'printMessage' that takes a single argument
                 * Note that we have now added a : after the function name
                 * delegate!.performSelector("printMessage:", withObject: "Hello World")
                 * printMessage looks like the following:
                 * func printMessage(arg: String) {
                 *     print(arg)
                 * }
                 *
                 * Call a function named 'printMessage' that takes two arguments.
                 * The max number of arguments you can send is two
                 * Note that we have now added two : after the function name
                 * delegate!.performSelector("printMessage::", withObject: "Hello", withObject: "World")
                 * printMessage looks like the following:
                 * func printMessage(arg: String, _ arg2: String) {
                 *     print("\(arg) \(arg2)")
                 * }
                 */
                delegate.store.send(
                    delegate.store.state.track.isPlaying
                    ? TrackAction.pause
                    : TrackAction.play
                )
            case NX_KEYTYPE_FAST:
                delegate.store.send(
                    delegate.store.state.track.isPlaying
                    ? TrackAction.playNext
                    : TrackAction.play
                )
            case NX_KEYTYPE_REWIND:
                print("Prev")
                break
            default:
                break
            }
        }
    }
}
