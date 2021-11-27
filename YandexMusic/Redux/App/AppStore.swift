//
//  AppStore.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

final class Store<State, Action>: ObservableObject {
    @Published private(set) var state: State

    private let appReducer: Reducer<State, Action>

    init(initialState: State, appReducer: Reducer<State, Action>) {
        self.state = initialState
        self.appReducer = appReducer
    }

    func send(_ action: Action) {
        appReducer.reduce(&state, action)
    }
}
