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

    private let openWindowHostPath = [
        "passport.yandex.ru/auth",
        "oauth.yandex.ru/authorize"
    ]

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
            .flatMap { title = "\($0) - \("login-title".localized)" }
        isReleasedWhenClosed = false
        styleMask.insert(NSWindow.StyleMask.fullSizeContentView)
        let viewModel = WebViewModel(link: Constants.Auth.codeUrl)
        contentView = NSHostingView(
            rootView: WebView(
                viewModel: viewModel,
                withResetCookies: AuthProviderImpl.instance.isNeedResetAuth
            )
        )
        AuthProviderImpl.instance.isNeedResetAuth = false
        cancellable = viewModel.$link.sink(receiveValue: { [weak self] link in
            let components = URLComponents(string: link)

            print("link \(link)")

            if components?.path.contains("verification_code") == true,
               let items = components?.queryItems?.first(where: { item in
                item.name == "code"
            }) {
                // GO TO AUTH
                self?.close()
            }
            else if let components = URLComponents(string: viewModel.link),
                    let host = components.host,
                    self?.openWindowHostPath.contains(host + components.path) == true
            {
                self?.makeKeyAndOrderFront(nil)
            }
        })
    }
}
