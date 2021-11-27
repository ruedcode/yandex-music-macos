//
//  Constants.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

enum Constants {
    enum Auth {
        static let clietnId = "15bfc573dab24b5d83243a913ab314c0"
        static let codeUrl = "https://oauth.yandex.ru/authorize?response_type=code&client_id=\(clietnId)"
        static let tokenUrl = "https://oauth.yandex.ru/token"
        static let clientSecret = "236cbbffd5524a4687445768afe4c0d1"
    }
    enum Collection {
        static let library = "https://music.yandex.ru/handlers/radio-library.jsx?lang=ru"
        static let recommendation = "https://music.yandex.ru/handlers/radio-recommended.jsx?lang=ru"
    }
}