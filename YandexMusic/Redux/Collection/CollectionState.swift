//
//  File.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

struct CollectionState {
    var stations: [Station] = []
}

struct Station: Hashable {
    let name: String
    let color: String
    let image: String
}
