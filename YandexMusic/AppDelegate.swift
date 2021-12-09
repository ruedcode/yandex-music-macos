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

    lazy var store: Store<AppState, AppAction> = {
        return Store<AppState, AppAction>(
            initialState: .init(),
            appReducer: appReducer,
            middlewares: [
                authMiddleware,
                stationMiddleware
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
        popover.contentSize = NSSize(width: 380, height: 150)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
        self.popover = popover
        
        // Create the status item
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        
        if let button = self.statusBarItem.button {
            button.image = NSImage(named: "Music")
            button.action = #selector(togglePopover(_:))
        }
        
        NSApp.activate(ignoringOtherApps: true)

        // Connect MPNowPlayingInfoCenter
        NowPlayingProvider.instance.handler = { [weak self] event in
            switch event {
            case .next: self?.store.send(TrackAction.playNext)
            case .play: self?.store.send(TrackAction.play)
            case .pause: self?.store.send(TrackAction.pause)
            }
        }
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = self.statusBarItem.button {
            if self.popover.isShown {
                self.popover.performClose(sender)
            } else {
                if case .authorized = store.state.auth {
                    self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                    self.popover.contentViewController?.view.window?.makeKey()
                }
                else {
                    auth()
                }
            }
        }
    }

    private func auth() {
        let authWindow = AuthWindow(store: store)
        authWindow.makeKeyAndOrderFront(self)
        cancellable = self.store.$state.sink { [weak self] state in
            if case .authorized = state.auth {
                self?.cancellable?.cancel()
                if let button = self?.statusBarItem.button {
                    self?.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                    self?.popover.contentViewController?.view.window?.makeKey()
                    self?.store.send(StationAction.fetch)
                }
            }
        }
    }
}
