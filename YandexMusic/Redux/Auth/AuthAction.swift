//
//  AuthAction.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

enum AuthAction: AppAction {
    case fetchToken(code: String)
    case update
    case authFailed
    case logout
}
