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
        let result = Result<AppAction, Never>.success(self)
        return AnyPublisher(result.publisher)
    }
}

enum BaseAction: AppAction {
    case resetState
}

extension Publisher {
    func ignoreError(
        _ action: ((Self.Failure) -> Void)? = nil,
        analytics: Bool = false
    ) -> Publishers.Catch<Self, AnyPublisher<Self.Output, Never>> {
        return self.catch { error -> AnyPublisher<Self.Output, Never> in
            log(error)
            action?(error)
            if analytics {
                (AssemblyRegistrator.instance.assembly.resolve() as Analytics).log(error: error)
            }
            return Empty(completeImmediately: true).eraseToAnyPublisher()
        }
    }
}
