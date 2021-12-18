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

        // Connect MPNowPlayingInfoCenter
        AudioProvider.instance.connect(to: store)

        changeIcons(mode: SettingsStorage.shared.appIconMode)
        
        NSApp.activate(ignoringOtherApps: true)

        NSApp.dockTile.contentView = NSHostingView(rootView: DockView(onUpdate: {
            DispatchQueue.main.async {
                NSApp.dockTile.display()
            }
        }).environmentObject(store))
        NSApp.dockTile.display()

        auth()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        togglePopover(self)
        return true
    }

    func changeIcons(mode: AppIconMode) {
        SettingsStorage.shared.appIconMode = mode
        switch mode {
        case .both:
            NSApp.dockTile.display()
            NSApp.setActivationPolicy(.regular)
//            statusBarItem.isVisible = true
//        case .dock:
//            NSApp.dockTile.display()
//            NSApp.setActivationPolicy(.regular)
//            statusBarItem.isVisible = false
        case .context:
//            statusBarItem.isVisible = true
            NSApp.setActivationPolicy(.prohibited)
        }
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

    func auth() {
        authWindow?.close()
        authWindow = AuthWindow(store: store)
        cancellable = self.store.$state.sink { [weak self] state in
            guard case .authorized = state.auth.mode else { return }
            self?.cancellable?.cancel()
            self?.cancellable = nil
            guard let button = self?.statusBarItem.button else { return }
            self?.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            self?.popover.contentViewController?.view.window?.makeKey()
            DispatchQueue.main.async {
                self?.store.send(StationAction.fetch)
            }
        }
    }
}
