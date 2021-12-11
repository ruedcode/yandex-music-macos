//
//  Library.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 05.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

struct LibraryRequest: RequestType {
    typealias ResponseType = LibraryResponse

    var data: RequestData {
        return RequestData(
            path: Constants.Collection.library,
            method: .get
        )
    }
}

struct LibraryResponse: Decodable {
    let groups: [GroupDTO]
    enum CodingKeys: String, CodingKey {
        case types
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dictionary = try container.decode([String: GroupDTO].self, forKey: .types) as [String: GroupDTO]
        groups = dictionary.map { $0.value }
    }
}

