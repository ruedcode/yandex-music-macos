//
//  AuthDTO.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//


struct Token: Decodable {
    let token_type: String
    let access_token: String
    let expires_in: Int
    let refresh_token: String
    let scope: String?
}

struct TokenReqest: Encodable {
    let grant_type = "authorization_code"
    let code: String
    let client_id: String
    let client_secret: String
}

struct FetchToken: RequestType {
    typealias ResponseType = Token

    let code: String
    var data: RequestData {
        return RequestData(
            path: Constants.Auth.tokenUrl,
            method: .post,
            params: .urlenencoded(
                TokenReqest(
                    code: code,
                    client_id: Constants.Auth.clietnId,
                    client_secret: Constants.Auth.clientSecret
                )
            )
        )
    }
}
