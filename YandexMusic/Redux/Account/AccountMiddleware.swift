//
//  AccountMiddleware.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 04.09.2023.
//  Copyright © 2023 Eugene Kalyada. All rights reserved.
//

import Foundation

var accountMiddleware: Middleware<AppState, AppAction> = { assembly, store, action in

    switch action {
    case AccountAction.fetch:
        UserSettingsRequest()
            .execute()
            .ignoreError()
            .flatMap { value in
                store.send(AccountAction.fetchedSettings(value))
                return AccountRequest()
                    .execute()
                    .ignoreError()
                    .eraseToAnyPublisher()
            }
            .sink { value in
                store.send(AccountAction.fetchedAccount(value))
            }
            .store(in: &store.effectCancellables)
        break

    default:
        break
    }
}

