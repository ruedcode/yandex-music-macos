//
//  AuthState.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

struct AuthState {
    var token: String
    var expiresIn: Int
    var refreshToken: String
    var scope: String
}
