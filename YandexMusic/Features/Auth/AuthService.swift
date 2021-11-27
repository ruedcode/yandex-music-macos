//
//  AuthService.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

final class AuthService {
    private let network: NetworkDispatcher

    init(network: NetworkDispatcher = URLSessionNetworkDispatcher.instance) {
        self.network = network
    }
}
