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
            appReducer: appReducer
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
            button.image = NSImage(named: "Music")
            button.action = #selector(togglePopover(_:))
        }

        let menu = NSMenu(title: "Menu")

        menu.addItem(
            withTitle: "Settings",
            action: #selector(openSettings),
            keyEquivalent: "s")

        menu.addItem(.separator())

        menu.addItem(
            withTitle: "Quit",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q")

        statusBarItem?.button?.menu = menu
        
        NSApp.activate(ignoringOtherApps: true)

        NowPlayingProvider.instance.onPlay = { [weak self] in
            self?.store.send(TrackAction.play)
        }

        NowPlayingProvider.instance.onNext = { [weak self] in
            self?.store.send(TrackAction.playNext)
        }

        NowPlayingProvider.instance.onPause = { [weak self] in
            self?.store.send(TrackAction.pause)
        }

        auth(showPopover: false)
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

    @objc private func openSettings() {
        SettingsView().openInWindow(title: "Settings", sender: self)
    }

    private func auth(showPopover: Bool = true) {
        authWindow?.close()
        authWindow = AuthWindow(store: store)
        cancellable = self.store.$state.sink { [weak self] state in
            if case .authorized = state.auth {
                self?.cancellable?.cancel()
                if let button = self?.statusBarItem.button {
                    if showPopover {
                        self?.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                        self?.popover.contentViewController?.view.window?.makeKey()
                    }
                    self?.store.send(CollectionAction.fetch)
                }
            }
        }
    }
}
