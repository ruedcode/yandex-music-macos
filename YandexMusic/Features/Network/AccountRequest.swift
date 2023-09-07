//
//  AccountRequest.swift
//  YandexMusic
//
//  Created by Mike Price on 11.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

struct AccountRequest: RequestType {
    typealias ResponseType = AccountResponse
    var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy { .convertFromSnakeCase }


    var data: RequestData {
        return RequestData(
            path: Constants.Auth.account,
            method: .get
        )
    }
}

// MARK: - AccountResponse
struct AccountResponse: Codable {
    let id: String
    let login: String
    let clientId: String
    let displayName: String
    let realName: String
    let firstName: String
    let lastName: String
    let sex: String
    let defaultAvatarId: String
    let isAvatarEmpty: Bool
    let psuid: String
}
