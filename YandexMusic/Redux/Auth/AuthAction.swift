//
//  AuthAction.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

enum AuthAction: AppAction {
    case auth(with: [HTTPCookie])
    case update
    case authFailed
    case logout
}
