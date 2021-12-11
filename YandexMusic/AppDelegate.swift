//
//  AppDelegate.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 12/18/19.
//  Copyright © 2019 Eugene Kalyada. All rights reserved.
//

import Cocoa
import Combine
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    private var cancellable: AnyCancellable?
    private var authWindow: AuthWindow?

    lazy var store: Store<AppState, AppAction> = {
        return Store<AppState, AppAction>(
            initialState: .init(),
            appReducer: appReducer,
            middlewares: [
                authMiddleware,
                stationMiddleware,
                trackMiddleware
            ]
        )
    }()

    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView().environmentObject(store)

        // Create the popover
        let popover = NSPopover()
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
        self.popover = popover

        // Create the status item
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        
        if let button = self.statusBarItem.button {
            button.image = NSImage(systemSymbolName: "music.note", accessibilityDescription: nil)
            button.action = #selector(contextAction)
        }

        // Create context menu
        let menu = NSMenu(title: "context-menu".localized)

        menu.addItem(
            withTitle: "quit".localized,
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q")

        statusBarItem?.button?.menu = menu
        
        NSApp.activate(ignoringOtherApps: true)

        // Connect MPNowPlayingInfoCenter
        NowPlayingProvider.instance.handler = { [weak self] event in
            switch event {
            case .next: self?.store.send(TrackAction.playNext)
            case .play: self?.store.send(TrackAction.play)
            case .pause: self?.store.send(TrackAction.pause)
            }
        }

        auth()
    }

    @objc func contextAction() {
        perform(#selector(togglePopover), with: nil, afterDelay: NSEvent.doubleClickInterval / 2)
        if NSApp.currentEvent?.clickCount == 2 {
            RunLoop.cancelPreviousPerformRequests(withTarget: self)
            store.send(store.state.track.isPlaying ? TrackAction.pause : TrackAction.play)
        }
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        guard let button = self.statusBarItem.button else { return }
        if self.popover.isShown {
            self.popover.performClose(sender)
        } else {
            if case .authorized = store.state.auth.mode {
                self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                self.popover.contentViewController?.view.window?.makeKey()
            }
            else {
                auth()
            }
        }
    }

    private func auth() {
        authWindow?.close()
        authWindow = AuthWindow(store: store)
        cancellable = self.store.$state.sink { [weak self] state in
            guard case .authorized = state.auth.mode else { return }
            self?.cancellable?.cancel()
            guard let button = self?.statusBarItem.button else { return }
            self?.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            self?.popover.contentViewController?.view.window?.makeKey()
            self?.store.send(StationAction.fetch)
        }
    }
}
