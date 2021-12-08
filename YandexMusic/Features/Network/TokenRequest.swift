//
//  Token.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 05.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

struct TokenRequest: RequestType {
    typealias ResponseType = TokenResponse

    let code: String
    var data: RequestData {
        return RequestData(
            path: Constants.Auth.tokenUrl,
            method: .post,
            params: .urlenencoded(
                Params(
                    code: code,
                    client_id: Constants.Auth.clientId,
                    client_secret: Constants.Auth.clientSecret
                )
            )
        )
    }

    struct Params: Encodable {
        let grant_type = "authorization_code"
        let code: String
        let client_id: String
        let client_secret: String
    }
}

struct TokenResponse: Decodable {
    let token_type: String
    let access_token: String
    let expires_in: Int
    let refresh_token: String
    let scope: String?
}
