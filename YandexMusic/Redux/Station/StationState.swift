//
//  SectionState.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

struct SectionState {
    var groups: [StationGroup] = []
    var stations: [Station] = []
    var station: Station?
    var stationGroup: StationGroup?
}

struct StationGroup: Hashable {
    let id: String
    let name: String
    let stations: [Station]
}

struct Station: Hashable {
    let type: String
    let tag: String
    let name: String
    let color: String
    let image: String
}

extension StationGroup {
    init(_ dto: GroupDTO) {
        id = dto.id
        name = dto.id == "user" ? "my-stations".localized : dto.name ?? "unknown-stations".localized
        stations = dto.children.map(Station.init)
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
