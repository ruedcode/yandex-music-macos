//
//  TrackService.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 01.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation
import Combine

struct TrackService {

    enum TrackError: Error {
        case noURL
    }

    let trackId: String
    let albumId: String

    func fetchUrl() -> AnyPublisher<URL, Error> {
        return Mp3Request(trackId: trackId, albumId: albumId)
            .execute()
            .map {
                "https:\($0.src)"
            }
            .flatMap {
                Mp3File(path: $0)
                    .execute()
                    .tryMap { cdn -> URL in
                        let path = "https://\(cdn.host)/get-mp3/falfn2o3finf023nn02nd0120192n012/\(cdn.ts)\(cdn.path)"
                        guard let url = URL(string: path) else {
                            throw TrackError.noURL
                        }
                        return url
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
