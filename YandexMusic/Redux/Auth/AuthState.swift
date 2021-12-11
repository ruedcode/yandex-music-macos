//
//  AuthState.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

struct AuthState {

    enum AuthMode {
        case authorized
        case unauthorized
    }

    var mode: AuthMode = .unauthorized
    var userName: String = ""
    var avatarHash: String?

    var avatarURL: URL? {
        guard let hash = avatarHash else { return nil }
        return URL(string: String(format: Constants.Auth.avatar, hash))
    }

}
