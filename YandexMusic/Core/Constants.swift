//
//  Constants.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import SwiftUI

enum Constants {
//https://www.cherkashin.dev/yandex-music-open-api/
    enum Auth {
        static let clientId = getFromConfig(key: "API_CLIENT_ID")
        static let clientSecret = getFromConfig(key: "API_CLIENT_SECRET")

        static let codeUrl = "https://oauth.yandex.ru/authorize?response_type=code&client_id=\(clientId)"
        static let tokenUrl = "https://oauth.yandex.ru/token"

        
        static let userSettings = "https://music.yandex.ru/api/v2.1/handlers/auth?external-domain=music.yandex.ru&overembed=no"

        // Заменить на https://login.yandex.ru/info
        static let account = "https://login.yandex.ru/info"
//        static let account = "https://api.passport.yandex.ru/suggested_accounts"

        static let avatar = "https://avatars.mds.yandex.net/get-yapic/%@/islands-retina-middle"
    }
    enum Collection {
        static let library = "https://music.yandex.ru/handlers/radio-library.jsx"
        static let recommendation = "https://music.yandex.ru/handlers/radio-recommended.jsx"
    }

    enum Track {
        static let list = "https://music.yandex.ru/api/v2.1/handlers/radio/%@/%@/tracks?queue=%@"
        static let mp3 = "https://music.yandex.ru/api/v2.1/handlers/track/%@:%@/web-radio-user-saved/download/m?hq=0"
        static let feedback = "https://music.yandex.ru/api/v2.1/handlers/radio/%@/%@/feedback/%@/%@:%@"
        static let like = "https://music.yandex.ru/api/v2.1/handlers/track/%@:%@/web-radio_page-track-track-main/like/add"
        static let unlike = "https://music.yandex.ru/api/v2.1/handlers/track/%@:%@/web-radio_page-track-track-main/like/remove"
        static let ban = "https://music.yandex.ru/api/v2.1/handlers/track/%@:%@/web-radio_page-track-track-main/dislike/add"
        static let share = "https://music.yandex.ru/album/%@/track/%@"
        static let feedback2 = "https://music.yandex.ru/api/v2.1/handlers/track/%@:%@/web-radio-user-main/feedback/%@"
        static let settings = "https://music.yandex.ru/api/v2.1/handlers/radio/%@/%@/settings?external-domain=music.yandex.ru&overembed=no"
    }

    enum Common {
        static let locale = "ru"
        static let imageSize = CGSize(width: 200, height: 200)
        static let primary: Color = Color(red: 1.00, green: 0.80, blue: 0.00)
        static let baseHeaders = [
            "X-Retpath-Y": "https://music.yandex.ru/radio",
            "X-Yandex-Music-Client": "YandexMusicAPI"
        ]
    }
}

fileprivate func getFromConfig(key: String) -> String {
    guard let val = Bundle.main.object(forInfoDictionaryKey: key) else {
        fatalError("Key '\(key)' not found in XCConfig")
    }
    return String(describing: val)
}
