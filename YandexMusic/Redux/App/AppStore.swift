//
//  AppStore.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation
import Combine

typealias Reducer<State, Action> =
    (inout State, Action) -> AnyPublisher<Action, Never>?

typealias Middleware<Store, Action> = (Store, Action) -> Void

final class Store<State, Action>: ObservableObject {
    @Published private(set) var state: State

    private let reducer: Reducer<State, Action>
    private let middlewares: [Middleware<Store, Action>]
    private var effectCancellables: Set<AnyCancellable> = []

    init(
        initialState: State,
        middlewares: [Middleware<Store, Action>] = [],
        appReducer: @escaping Reducer<State, Action>
    ) {
        self.state = initialState
        self.reducer = appReducer
        self.middlewares = middlewares
    }

    func send(_ action: Action) {

        middlewares.forEach {
            $0(self, action)
        }
        
        guard let effect = reducer(&state, action) else {
            return
        }

        effect
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: send)
            .store(in: &effectCancellables)
    }
}
