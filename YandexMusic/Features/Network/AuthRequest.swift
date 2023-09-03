//
//  AuthRequest.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 03.09.2023.
//  Copyright © 2023 Eugene Kalyada. All rights reserved.
//

import Foundation

import Foundation

struct AuthCodeRequest: RequestType {
    typealias ResponseType = AuthCodeResponse


    var data: RequestData {
        return RequestData(
            path: Constants.Auth.codeUrl,
            method: .get
        )
    }
}

struct AuthCodeResponse: Codable {
    let code: String
    let state: String
}
