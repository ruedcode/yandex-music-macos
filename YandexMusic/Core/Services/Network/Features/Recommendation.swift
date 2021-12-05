//
//  Recommendation.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 05.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

struct RecommendationRequest: RequestType {
    typealias ResponseType = RecomendationResponse

    var data: RequestData {
        return RequestData(
            path: Constants.Collection.recommendation,
            method: .get,
            auth: true
        )
    }
}

struct RecomendationResponse: Decodable {
    let stations: [ItemDTO]

    struct ItemDTO: Decodable {
        let station: StationDTO
    }
}
