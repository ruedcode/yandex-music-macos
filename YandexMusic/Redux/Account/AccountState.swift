//
//  AccountState.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 05.09.2023.
//  Copyright © 2023 Eugene Kalyada. All rights reserved.
//

import Foundation

struct AccountState {
    var id: String = ""
    var login: String = ""
    var clientId: String = ""
    var displayName: String = ""
    var realName: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var sex: String = ""
    var defaultAvatarId: String = ""
    var isAvatarEmpty: Bool = true
    var psuid: String = ""
    var csrf: String = ""

    var avatarURL: URL? {
        guard !defaultAvatarId.isEmpty else { return nil }
        return URL(string: String(format: Constants.Auth.avatar, defaultAvatarId))
    }

}
