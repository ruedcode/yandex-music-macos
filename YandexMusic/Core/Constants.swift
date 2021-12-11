//
//  Constants.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation
import SwiftUI

enum Constants {
    enum Auth {
        static let clientId = getFromConfig(key: "API_CLIENT_ID")
        static let codeUrl = "https://oauth.yandex.ru/authorize?response_type=code&client_id=\(clientId)"
        static let tokenUrl = "https://oauth.yandex.ru/token"
        static let clientSecret = getFromConfig(key: "API_CLIENT_SECRET")
        static let userSettings = "https://music.yandex.ru/api/v2.1/handlers/auth?external-domain=music.yandex.ru&overembed=no"
        static let account = "https://api.passport.yandex.ru/suggested_accounts"
        static let avatar = "https://avatars.mds.yandex.net/get-yapic/%@/islands-retina-middle"
    }
    enum Collection {
        static let library = "https://music.yandex.ru/handlers/radio-library.jsx?lang=ru"
        static let recommendation = "https://music.yandex.ru/handlers/radio-recommended.jsx?lang=ru"
    }

    enum Track {
        static let list = "https://music.yandex.ru/api/v2.1/handlers/radio/%@/%@/tracks?queue=%@"
        static let mp3 = "https://music.yandex.ru/api/v2.1/handlers/track/%@:%@/web-radio-user-saved/download/m?hq=0"
        static let feedback = "https://music.yandex.ru/api/v2.1/handlers/radio/%@/%@/feedback/%@/%@:%@"
        static let like = "https://music.yandex.ru/api/v2.1/handlers/track/%@:%@/web-radio_page-track-track-main/like/add"
        static let unlike = "https://music.yandex.ru/api/v2.1/handlers/track/%@:%@/web-radio_page-track-track-main/like/remove"
        static let share = "https://music.yandex.ru/album/%@/track/%@"
        static let feedback2 = "https://music.yandex.ru/api/v2.1/handlers/track/%@:%@/web-radio-user-main/feedback/%@"

    }

    enum Common {
        static let imageSize = CGSize(width: 200, height: 200)
        static let primary: Color = Color(red: 1.00, green: 0.80, blue: 0.00)
    }
}

fileprivate func getFromConfig(key: String) -> String {
    guard let val = Bundle.main.object(forInfoDictionaryKey: key) else {
        fatalError("Key '\(key)' not found in XCConfig")
    }
    return String(describing: val)
}
