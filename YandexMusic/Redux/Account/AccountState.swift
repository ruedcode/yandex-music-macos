//
//  AccountState.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 05.09.2023.
//  Copyright © 2023 Eugene Kalyada. All rights reserved.
//

import Foundation

struct AccountState {
    var csrf: String = ""
    var uid: String = ""
    var login: String = ""
    var yandexuid: String = ""
    var premium: Bool = false
    var userName: String = ""
    var avatarHash: String?

    var avatarURL: URL? {
        guard let hash = avatarHash else { return nil }
        return URL(string: String(format: Constants.Auth.avatar, hash))
    }

}
