//
//  AuthRequest.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 03.09.2023.
//  Copyright © 2023 Eugene Kalyada. All rights reserved.
//

import Foundation

struct AuthCodeResponse: Codable {
    let accessToken: String
    let expiresIn: Int
    let tokenType: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.accessToken = try container.decode(String.self, forKey: .accessToken)
        self.tokenType = try container.decode(String.self, forKey: .tokenType)
        if let expiresIn = try? container.decode(String.self, forKey: .expiresIn), let intVal = Int(expiresIn) {
            self.expiresIn = intVal
        }
        else {
            self.expiresIn = try container.decode(Int.self, forKey: .expiresIn)
        }
    }
}
