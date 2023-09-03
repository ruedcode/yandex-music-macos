//
//  AuthMiddleware.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 08.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

var authMiddleware: Middleware<AppState, AppAction> = { store, action in
    switch action {
    case let AuthAction.auth(code):
        Analytics.shared.log(event: .login)
//        AuthProviderImpl.instance
//            .auth(with: cookies)
//            .ignoreError()
//            .sink { _ in store.send(AuthAction.update) }
//            .store(in: &store.effectCancellables)

    case AuthAction.logout:
        Stored<Void>.clear()
        AuthProviderImpl.instance.logout()

    default:
        break
    }
}
