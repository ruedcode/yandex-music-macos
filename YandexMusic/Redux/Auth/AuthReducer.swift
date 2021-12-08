//
//  AuthReducer.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation
import Combine

func authReducer(
    state: inout AuthState,
    action: AppAction
) -> AnyPublisher<AppAction, Never>? {
    switch action {
    case AuthAction.fetchToken(let code):
        return AuthProvider.instance
            .auth(with: code)
            .map { AuthAction.updateToken }
            .ignoreError()
            .eraseToAnyPublisher()

    case AuthAction.updateToken:
        state = AuthProvider.instance.token != nil ? .authorized : .unauthorized

    case AuthAction.logout:
        HTTPCookieStorage.shared
            .cookies?
            .forEach(HTTPCookieStorage.shared.deleteCookie)
        URLCache.shared.removeAllCachedResponses()
        URLSession.shared.invalidateAndCancel()
        AuthProvider.instance.logout()
        return Just(AuthAction.updateToken)
            .eraseToAnyPublisher()

    default:
        break
    }

    return nil
}
