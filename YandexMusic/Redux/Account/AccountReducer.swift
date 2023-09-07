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
    case let AccountAction.fetchedAccount(account):
        state.id = account.id
        state.login = account.login
        state.clientId = account.clientId
        state.displayName = account.displayName
        state.realName = account.realName
        state.firstName = account.firstName
        state.lastName = account.lastName
        state.sex = account.sex
        state.defaultAvatarId = account.defaultAvatarId
        state.isAvatarEmpty = account.isAvatarEmpty
        state.psuid = account.psuid
    case let AccountAction.fetchedSettings(settings):
        state.csrf = settings.csrf
    default:
        break
    }
    return nil
}
