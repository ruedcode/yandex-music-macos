//
//  AppAction.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Combine

protocol AppAction {
}

extension AppAction {
    var next: AnyPublisher<AppAction, Never> {
        return Future<AppAction, Error>() { promise in
            promise(.success(self))
        }.catch { _ in
            Empty(completeImmediately: true)
        }.eraseToAnyPublisher()
    }
}

enum BaseAction: AppAction {
    case dumb(Error)
}
