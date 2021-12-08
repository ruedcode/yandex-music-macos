//
//  AuthWindow.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import SwiftUI
import Combine

final class AuthWindow: NSWindow {
    private let store: Store<AppState, AppAction>

    private var cancellable: AnyCancellable?

    init(store: Store<AppState, AppAction>) {
        self.store = store
        let size = CGSize(width: 480, height: 850)
        var point = CGPoint.zero
        if let frame = NSScreen.main?.frame {
            point.x = (frame.width - size.width) / 2
            point.y = (frame.height - size.height) / 2
        }

        super.init(
            contentRect: NSRect(origin: point, size: size),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        Bundle.main.infoDictionary?["CFBundleName"]
            .flatMap { title = "\($0) - Login" }
        level = .popUpMenu
        makeKeyAndOrderFront(nil)
        isReleasedWhenClosed = false
        styleMask.insert(NSWindow.StyleMask.fullSizeContentView)
        let viewModel = WebViewModel(link: Constants.Auth.codeUrl)
        contentView = NSHostingView(rootView: WebView(viewModel: viewModel))
        cancellable = viewModel.$link.sink { [weak self] link in
            guard
                let components = URLComponents(string: link),
                components.path == "/verification_code",
                let code = components.queryItems?.first(where: {
                    $0.name == "code" && $0.value?.isEmpty == false
                })?.value
            else {
                return
            }
            self?.store.send(AuthAction.fetchToken(code: code))
            self?.close()
        }
    }
}
