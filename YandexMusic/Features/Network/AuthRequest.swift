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
    var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .convertFromSnakeCase

    var isAuth: Bool { false }

    let code: String

    var data: RequestData {
        let auth = (Constants.Auth.clientId + ":" + Constants.Auth.clientSecret).toBase64()
        return RequestData(
            path: Constants.Auth.tokenUrl,
            method: .post,
            params: .urlenencoded(
                Form(
                    code: code
                )
            ),
            headers: ["Authorization": "Basic \(auth)"]
        )
    }

    fileprivate struct Form: Encodable {
        let grantType: String = "authorization_code"
        let code: String
        let scope: String = "login:avatar login:info"

        enum CodingKeys: String, CodingKey {
            case code
            case grantType = "grant_type"
        }
    }
}

struct AuthCodeResponse: Codable {
    let accessToken: String
    let expiresIn: Int
    let refreshToken: String
    let tokenType: String
}
