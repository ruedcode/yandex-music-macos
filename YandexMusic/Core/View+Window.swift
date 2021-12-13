//
//  View+Window.swift
//  YandexMusic
//
//  Created by Mike Price on 13.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import SwiftUI

extension View {
    @discardableResult
    func openInWindow(title: String, sender: Any?) -> NSWindow {
        let window = NSWindow(contentViewController: NSHostingController(rootView: self))
        Bundle.main.infoDictionary?["CFBundleName"]
            .flatMap { window.title = "\($0) - \(title.localized)" }
        window.canHide = false
        window.level = .popUpMenu
        window.makeKeyAndOrderFront(sender)
        return window
    }
}
