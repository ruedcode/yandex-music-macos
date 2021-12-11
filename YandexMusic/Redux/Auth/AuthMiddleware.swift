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
    case AuthAction.fetchToken(let code):
        Analytics.shared.log(event: .login)
        AuthProvider.instance
            .auth(with: code)
            .ignoreError()
            .sink { _ in store.send(AuthAction.update) }
            .store(in: &store.effectCancellables)

    case AuthAction.logout:
        HTTPCookieStorage.shared
            .cookies?
            .forEach(HTTPCookieStorage.shared.deleteCookie)
        URLCache.shared.removeAllCachedResponses()
        URLSession.shared.invalidateAndCancel()
        AuthProvider.instance.logout()

    default:
        break
    }
}
