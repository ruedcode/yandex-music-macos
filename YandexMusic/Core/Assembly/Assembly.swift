//
//  Assembly.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 03.09.2023.
//  Copyright © 2023 Eugene Kalyada. All rights reserved.
//

import Foundation

final class Assembly {

    enum Strategy {
        case last
        case new
    }

    private var registrations: [String: ContainerValue] = [:]

    func register<T>(initializer: @escaping (Assembly) -> T, initImmediately: Bool = false) {
        let type = name(for: T.self)
        let value = ContainerValue(initializer)
        if initImmediately {
            let _: T? = value.resolve(assembly: self, cached: false)
        }
        registrations[type] = value
    }

    func resolve<T>(strategy: Strategy = .new) -> T {
        let type = name(for: T.self)

        guard let container = registrations[type] else {
            fatalError("Could not find type: \(type)")
        }

        guard let value: T = container.resolve(assembly: self, cached: strategy == .last) else {
            fatalError("Could not resolve type: \(type)")
        }
        return value
    }

    private func name(for type: Any.Type) -> String {
        var rawName = String(describing: type)
        if rawName.hasPrefix("Optional<") {
            rawName = String(rawName.dropFirst(9))
            rawName = String(rawName.dropLast(1))
        }
        return rawName
    }
}

private class ContainerValue {
    private var _cachedInstance: Any?
    private let resolver: (Assembly) -> Any

    init(_ resolver: @escaping (Assembly) -> Any) {
        self.resolver = resolver
    }

    func resolve<T>(assembly: Assembly, cached: Bool) -> T? {
        if cached, let instance = _cachedInstance {
            return instance as? T
        }
        let instance = resolver(assembly)
        _cachedInstance = instance
        return instance as? T
    }
}
