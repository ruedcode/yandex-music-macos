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
    private lazy var statusBarPlayerView: NSImageView = {
        let view = NSImageView(frame: CGRect(x: 0, y: 0, width: 8, height: 8))
        view.image = NSImage(systemSymbolName: "play.fill", accessibilityDescription: nil)
        view.isHidden = true
        return view
    }()

    lazy var store: Store<AppState, AppAction> = {
        return Store<AppState, AppAction>(
            initialState: .init(),
            appReducer: appReducer,
            middlewares: [
                authMiddleware,
                stationMiddleware,
                trackMiddleware,
                playerSettingsMiddleware
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

        AudioProvider.instance.connect(to: store)

        // Create the status item
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))

        if let button = self.statusBarItem.button {
            button.image = NSImage(systemSymbolName: "music.note", accessibilityDescription: nil)
            button.action = #selector(contextAction)
            button.addSubview(statusBarPlayerView)
            statusBarPlayerView.frame = CGRect(
                x: button.bounds.width - statusBarPlayerView.frame.width - 4,
                y: button.bounds.height - statusBarPlayerView.frame.height - 7,
                width: statusBarPlayerView.frame.width,
                height: statusBarPlayerView.frame.height
            )
        }

        changeIcons(mode: SettingsStorage.shared.appIconMode)
        
        NSApp.activate(ignoringOtherApps: true)

        NSApp.dockTile.contentView = NSHostingView(rootView: DockView(onUpdate: {
            DispatchQueue.main.async {
                NSApp.dockTile.display()
            }
        }).environmentObject(store))
        NSApp.dockTile.display()
        subscribePlayer()

        auth()
        Analytics.shared.log(event: .open)
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
        case .context:
            NSApp.setActivationPolicy(.accessory)
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

    private func subscribePlayer() {
        AudioProvider.instance.state.$status.sink { [weak self] status in
            guard let self = self else {
                return
            }
            self.statusBarPlayerView.isHidden = true
            switch status {
            case let .start(time):
                self.store.send(TrackAction.updateTotal(time))
                self.store.send(TrackAction.sendFeedback(.radioStarted))
                self.store.send(
                    TrackAction.feedbackStationStartUpdate(
                        type: self.store.state.track.lastType,
                        tag: self.store.state.track.lastTag
                    )
                )
                self.store.send(TrackAction.sendFeedback(.trackStarted))
                self.statusBarPlayerView.isHidden = false
            case .finish:
                self.store.send(TrackAction.sendFeedback(.trackFinished))
                self.store.send(TrackAction.playNext)
            case let .failure(error):
                self.store.send(TrackAction.sendFeedback(.skip))
                self.store.send(TrackAction.playNext)
                if let error = error {
                    Analytics.shared.log(error: error)
                    log(error)
                }

            case let .playing(time):
                self.store.send(TrackAction.updateCurrent(time))
                self.statusBarPlayerView.isHidden = false
            default: break
            }
        }.store(in: &self.store.effectCancellables)
    }
}
