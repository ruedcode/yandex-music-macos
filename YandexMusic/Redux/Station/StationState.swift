//
//  SectionState.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

struct SectionState {
    var groups: [StationGroup] = []
    var stations: [Station] = []
    var station: Station?
    var stationGroup: StationGroup?
    var error: ErrorState?
}

struct StationGroup: Hashable {
    let id: String
    var name: String {
        isUser ? "my-stations".localized : _name
    }
    let stations: [Station]
    var isUser: Bool {
        id == "user"
    }

    private let _name: String
}

struct Station: Hashable, Identifiable {

    let type: String
    let tag: String
    let name: String
    let color: String
    let image: String

    var id: String {
        tag
    }
}

extension StationGroup {
    init(_ dto: GroupDTO) {
        id = dto.id
        _name = dto.name ?? "unknown-stations".localized
        stations = dto.children?.map(Station.init) ?? []
    }
}

extension Station {
    init(_ dto: StationDTO) {
        type = dto.id.type
        tag = dto.id.tag
        name = dto.name
        color = dto.icon.backgroundColor
        image = link(from: dto.icon.imageUrl)
    }
}

extension Array where Element == StationGroup {
    var sorted: [StationGroup] {
        self.sorted(by: { item1, item2 in
            if item1.isUser {
                return true
            }
            if item2.isUser {
                return false
            }
            return item1.id <= item2.id
        }).filter { !$0.stations.isEmpty }
    }
}
