//
//  Analytics.swift
//  YandexMusic
//
//  Created by Mike Price on 11.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

//import Firebase
//import FirebaseAnalytics
import Foundation

enum AnalyticsEvent: String {
    case login
    case logout
    case share
    case viewItem
    case viewScreen
    case selectItem
    case play
    case pause
    case next
    case open
    case like
    case unlike

//    fileprivate var eventName: String {
//        let dict: [AnalyticsEvent: String] = [
//            .login: AnalyticsEventLogin,
//            .share: AnalyticsEventShare,
//            .viewScreen: AnalyticsEventScreenView,
//            .viewItem: AnalyticsEventViewItem,
//            .selectItem: AnalyticsEventSelectItem,
//            .play: "play",
//            .pause: "pause",
//            .next: "next",
//            .open: AnalyticsEventAppOpen,
//            .like: "like",
//            .unlike: "unlike"
//        ]
//        return dict[self] ?? self.rawValue
//    }
}

protocol Analytics {
    func set(userId: String?)

    func log(event: AnalyticsEvent)

    /// Log event to Analytics
    func log(event: AnalyticsEvent, params: [String: Any])

    /// Log message to Crashlytics for collecting with error or crash
    func log(message: String)

    /// Log error to Crashlytics
    func log(error: Error)

}

final class AnalyticsImpl: Analytics {

    init() {
        UserDefaults.standard.register(
            defaults: ["NSApplicationCrashOnExceptions" : true]
        )
//        FirebaseApp.configure()
    }

    /// Set UserID for Analytics/Crashlytics
    func set(userId: String?) {
//        Firebase.Analytics.setUserID(userId)
//        userId.flatMap { Firebase.Crashlytics.crashlytics().setUserID($0) }
    }

    /// Log event to Analytics
    func log(event: AnalyticsEvent) {
//        Firebase.Analytics.logEvent(event.eventName, parameters: params)
    }

    /// Log event to Analytics
    func log(event: AnalyticsEvent, params: [String: Any]) {
//        Firebase.Analytics.logEvent(event.eventName, parameters: params)
    }

    /// Log message to Crashlytics for collecting with error or crash
    func log(message: String) {
//        Firebase.Crashlytics.crashlytics().log(message)
    }

    /// Log error to Crashlytics
    func log(error: Error) {
//        Firebase.Crashlytics.crashlytics().record(error: error)
    }
}
