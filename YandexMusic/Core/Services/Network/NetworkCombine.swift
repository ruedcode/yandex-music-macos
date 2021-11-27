//
//  NetworkCombine.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Combine

extension RequestType {
    func execute(dispatcher: NetworkDispatcher = URLSessionNetworkDispatcher.instance) -> AnyPublisher<ResponseType, Error> {
        return Future() { promise in
            execute { result in
                promise(result)
            }
        }.eraseToAnyPublisher()
    }
}
