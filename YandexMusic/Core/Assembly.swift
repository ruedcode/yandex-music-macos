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

    private var registrations: [ContainerType: ContainerValue] = [:]


    func register<T>(initializer: @escaping (Assembly) -> T, initImmediately: Bool = false) {

    }

    func resolve<T>(strategy: Strategy = .new) -> T {
        let type = ContainerType(T.self)

        guard let container = registrations[type] else {
            fatalError("Could not find type: \(type)")
        }

        guard let value: T = container.resolve(assembly: self, cached: strategy == .last) else {
            fatalError("Could not resolve type: \(type)")
        }
        return value
    }
}

extension Assembly {
    private class ContainerType: Hashable {

        private let type: String

        init(_ type: Any.Type) {
            self.type = "\(type)"
        }

        static func == (lhs: Assembly.ContainerType, rhs: Assembly.ContainerType) -> Bool {
            lhs.type == rhs.type
        }

        public var debugDescription: String {
            return "registered type: \(type)"
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(type)
        }
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
