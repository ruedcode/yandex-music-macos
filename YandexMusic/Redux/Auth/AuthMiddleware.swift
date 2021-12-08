//
//  AuthMiddleware.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 08.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation
import Combine

var authMiddleware: Middleware<AppState, AppAction> = {
    { store, action in
        switch action {
        case AuthAction.fetchToken(let code):
            AuthProvider.instance
                .auth(with: code)
                .ignoreError()
                .sink { _ in
                    store.send(AuthAction.updateToken)
                }.store(in: &store.effectCancellables)
        default:
            break
        }
    }
}

