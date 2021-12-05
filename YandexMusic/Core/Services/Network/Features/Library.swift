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
            method: .get,
            auth: true
        )
    }
}

struct LibraryResponse: Decodable {
    let types: GroupsDTO?
}

