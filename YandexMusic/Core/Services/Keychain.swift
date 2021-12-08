//
//  Keychain.swift
//  YandexMusic
//
//  Created by Mike Price on 08.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation
import Security

@propertyWrapper
struct KeychainValue<Value: Codable> {
    let key: KeychainKey

    init(key: KeychainKey) {
        self.key = key
    }

    var wrappedValue: Value? {
        get { Keychain.shared.get(for: key) }
        set {
            guard let newValue = newValue else {
                Keychain.shared.delete(for: key)
                return
            }
            Keychain.shared.set(newValue, for: key)
        }
    }
}

final class Keychain {
    static var shared = Keychain()

    private let service: String = "YandexMusic"

    func get<T: Codable>(for key: KeychainKey) -> T? {
        let query = keychainQuery(key.rawValue)
        query[kSecMatchLimit] = kSecMatchLimitOne
        query[kSecReturnAttributes] = kCFBooleanTrue
        query[kSecReturnData] = kCFBooleanTrue

        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query, UnsafeMutablePointer($0))
        }

        guard
            status == noErr,
            let existingItem = queryResult as? NSDictionary,
            let data = existingItem[kSecValueData] as? Data
        else {
            log("Keychain reading data for key \"\(key)\" failed: \(status)")
            return nil
        }

        return try? JSONDecoder().decode(T.self, from: data)
    }

    func set<T: Codable>(_ value: T, for key: KeychainKey) {
        guard let data = try? JSONEncoder().encode(value) else {
            log("Keychain value mapping error for key \"\(key.rawValue)\"")
            return
        }
        let query = keychainQuery(key.rawValue)
        if let _: T = get(for: key) {
            let attributesToUpdate = NSMutableDictionary()
            attributesToUpdate[kSecValueData] = data
            let status = SecItemUpdate(query, attributesToUpdate)
            log("Keychain updating data for key \"\(key.rawValue)\" has completed with status: \(status)")
        } else {
            query[kSecValueData] = data
            let status = SecItemAdd(query, nil)
            log("Keychain saving data for key \"\(key.rawValue)\" has completed with status: \(status)")
        }
    }

    func delete(for key: KeychainKey) {
        SecItemDelete(keychainQuery(key.rawValue))
        log("Keychain value for key \"\(key.rawValue)\" was deleted")
    }

    private func keychainQuery(_ key: String) -> NSMutableDictionary {
        let query = NSMutableDictionary()
        query[kSecClass] = kSecClassGenericPassword
        query[kSecAttrService] = service
        query[kSecAttrAccessGroup] = Bundle.main.bundleIdentifier
        query[kSecAttrAccount] = key
        query[kSecAttrAccessible] = kSecAttrAccessibleWhenUnlocked
        return query
    }
}

enum KeychainKey: String {
    case token = "AuthToken"
    case profile = "Profile"
}
