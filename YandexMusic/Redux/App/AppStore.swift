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

final class Store<State, Action>: ObservableObject {
    @Published private(set) var state: State

    private let reducer: Reducer<State, Action>
    private var effectCancellables: Set<AnyCancellable> = []

    init(initialState: State, appReducer: @escaping Reducer<State, Action>) {
        self.state = initialState
        self.reducer = appReducer
    }

    func send(_ action: Action) {
        
        guard let effect = reducer(&state, action) else {
            return
        }

        effect
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: send)
            .store(in: &effectCancellables)
    }
}
