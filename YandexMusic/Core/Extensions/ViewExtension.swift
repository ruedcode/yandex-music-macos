//
//  ViewExtension.swift
//  YandexMusic
//
//  Created by Mike Price on 08.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import SwiftUI

extension View {
    @discardableResult
    func openInWindow(title: String, sender: Any?) -> NSWindow {
        let window = NSWindow(contentViewController: NSHostingController(rootView: self))
        Bundle.main.infoDictionary?["CFBundleName"]
            .flatMap { window.title = "\($0) - \(title)" }
        window.level = .popUpMenu
        window.makeKeyAndOrderFront(sender)
        return window
    }
}
