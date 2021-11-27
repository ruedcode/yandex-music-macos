//
//  AuthProvider.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation
import Combine

final class AuthProvider {
    static let instance = AuthProvider()


    func requestToken(code: String) -> AnyPublisher<Token, Error> {
        return FetchToken(code: code).execute()
    }
}
