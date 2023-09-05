//
//  AccountReducer.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 05.09.2023.
//  Copyright © 2023 Eugene Kalyada. All rights reserved.
//

import Foundation
import Combine
import Cocoa

func accountReducer(
    state: inout AccountState,
    action: AppAction
) -> AnyPublisher<AppAction, Never>? {
    switch action {
    case let AccountAction.fetchedSettings(settings):
        state.csrf = settings.csrf
        state.login = settings.login ?? ""
        state.premium = settings.premium
        state.uid = settings.uid
        state.yandexuid = settings.yandexuid
    case let AccountAction.fetchedAccount(accounts):
        guard let account = accounts.accounts.first else { break }
        state.userName = account.displayName
        state.avatarHash = account.avatar.avatarDefault
    default:
        break
    }
    return nil
}
