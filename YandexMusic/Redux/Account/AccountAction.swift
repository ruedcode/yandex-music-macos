//
//  AccountAction.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 04.09.2023.
//  Copyright © 2023 Eugene Kalyada. All rights reserved.
//

import Foundation

import Foundation

enum AccountAction: AppAction {
    case fetch

    case fetchedSettings(UserSettingsResponse)
    case fetchedAccount(AccountResponse)
}
