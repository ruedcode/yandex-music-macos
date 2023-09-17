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
    private let authProvider: AuthProvider

    private let openWindowHostPath = [
        "passport.yandex.ru/auth",
        "oauth.yandex.ru/authorize"
    ]

    private var cancellable: AnyCancellable?

    init(store: Store<AppState, AppAction>, authProvider: AuthProvider) {
        self.store = store
        self.authProvider = authProvider
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
                withResetCookies: false //AuthProviderImpl.instance.isNeedResetAuth
            )
        )
//        self.authProvider.isNeedResetAuth = false
        cancellable = viewModel.$link.sink(receiveValue: { [weak self] link in
            let components = URLComponents(string: link)


            if let framgents = components?.fragment, framgents.contains("access_token=") {
//                let wtf = framgents.split(separator: "&").map ({
//                    let item = $0.split(separator: "=")
//                    return URLQueryItem(name: String(item.first ?? ""), value: String(item.last ?? ""))
//                })
//                            print("items", wtf)
                store.send(AuthAction.auth(tokenString: framgents))
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
