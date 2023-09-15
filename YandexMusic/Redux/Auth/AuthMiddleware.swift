//
//  AuthMiddleware.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 08.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

var authMiddleware: Middleware<AppState, AppAction> = { assembly, store, action in
    let authProvider: AuthProvider = assembly.resolve(strategy: .last)
    let analytics: Analytics = assembly.resolve()
    switch action {
    case let AuthAction.auth(code):
        analytics.log(event: .login)
        authProvider.auth(code: code)
        // TODO: - Обработка ошибки
            .ignoreError()
            .sink {
                guard authProvider.isAuth else {
                    store.send(AuthAction.authFailed)
                    store.send(AuthAction.logout)
                    return
                }
                store.send(AccountAction.fetch)
            }
            .store(in: &store.effectCancellables)


    case AuthAction.logout:
        Stored<Void>.clear()
        authProvider.logout()

    default:
        break
    }
}
