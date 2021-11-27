//
//  CollectionReducer.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation
import Combine

func collectionReducer(
    state: inout CollectionState,
    action: CollectionAction
) -> AnyPublisher<AppAction, Never> {
    let fetcher = FetchCollection()
    switch action {
    case .fetch:
        return fetcher.execute()
            .map {
                CollectionAction.update($0)
            }
            .catch { error in
                Empty(completeImmediately: true)
            }
            .eraseToAnyPublisher()
    case .update(let items):

        func makeStations(from group: CollectionDTO.GroupsDTO.GroupDTO) -> [Station] {
            return group.children.compactMap {
                Station(
                    name: $0.name,
                    color: $0.icon.backgroundColor,
                    image: "https://" + $0.icon.imageUrl.replacingOccurrences(of: "%%", with: "200x200")
                )
            }
        }
        if let type = items.types {
            var stations: [Station] = []
            stations.append(contentsOf: makeStations(from: type.user))
//            stations.append(contentsOf: makeStations(from: type.genre))
//            stations.append(contentsOf: makeStations(from: type.activity))
//            stations.append(contentsOf: makeStations(from: type.author))
            state.stations = stations
        }

    default:
        break
    }
    return Empty().eraseToAnyPublisher()
}

