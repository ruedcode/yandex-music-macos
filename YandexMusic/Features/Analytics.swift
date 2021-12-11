//
//  Analytics.swift
//  YandexMusic
//
//  Created by Mike Price on 11.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Firebase
import Foundation

enum AnalyticsEvent: String {
    case login
    case logout
}

final class Analytics {
    static let shared = Analytics()

    private init() {
        UserDefaults.standard.register(
            defaults: ["NSApplicationCrashOnExceptions" : true]
        )
        FirebaseApp.configure()
    }

    /// Set UserID for Analytics/Crashlytics
    func set(userId: String?) {
        Firebase.Analytics.setUserID(userId)
        userId.flatMap { Firebase.Crashlytics.crashlytics().setUserID($0) }
    }

    /// Log event to Analytics
    func log(event: AnalyticsEvent, params: [String: Any]? = nil) {
        Firebase.Analytics.logEvent(event.rawValue, parameters: params)
    }

    /// Log message to Crashlytics for collecting with error or crash
    func log(message: String) {
        Firebase.Crashlytics.crashlytics().log(message)
    }

    /// Log error to Crashlytics
    func log(error: Error) {
        Firebase.Crashlytics.crashlytics().record(error: error)
    }
}
