//
//  NotificationService.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 23.11.2022.
//  Copyright © 2022 Eugene Kalyada. All rights reserved.
//

import Foundation
import UserNotifications

final class NotificationProvider {

    enum NotificationProviderError: Error {
        case dataNotFound
    }

    static let instance = NotificationProvider()

    private var isEnabled: Bool = false
    private let center: UNUserNotificationCenter
    private let uid = UUID().uuidString

    init() {
        self.center = UNUserNotificationCenter.current()
    }

    func requestStatus() {
        center.requestAuthorization(options: [.alert, .sound], completionHandler: { [weak self] result, _ in
            self?.isEnabled = result
        })
    }

    func notify(title: String, text: String, url: URL?) {
        guard isEnabled else { return }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = text
        content.sound = .none

        if let url = url {
            makeAttachment(url: url) { [weak self] attachment in
                if let attachment = attachment {
                    content.attachments = [
                        attachment
                    ]
                }
                self?.makeNotification(content: content)
            }
        }
        else {
            makeNotification(content: content)
        }

    }

    private func makeNotification(content: UNNotificationContent) {
        let request = UNNotificationRequest(
            identifier: uid,
            content: content,
            trigger: nil
        )
        center.removeDeliveredNotifications(withIdentifiers: [uid])
        center.add(request)
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 10) {
            self.center.removeDeliveredNotifications(withIdentifiers: [self.uid])
        }
    }

    private func makeAttachment(url: URL, completion: @escaping (UNNotificationAttachment?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let dir = "albums"
            let identifier = UUID().uuidString + ".jpeg"
            do {
                let data = try Data(contentsOf: url)
                let directory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(dir, isDirectory: true)
                let fileURL = directory.appendingPathComponent(identifier)
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
                try data.write(to: fileURL, options: [])
                completion(try UNNotificationAttachment(identifier: identifier, url: fileURL))
            }
            catch {
                completion(nil)
            }
        }

    }
}
