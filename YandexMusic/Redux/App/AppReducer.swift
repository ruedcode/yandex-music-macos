//
//  Reducer.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

struct Reducer<State, Action> {
    let reduce: (inout State, Action) -> Void
}
