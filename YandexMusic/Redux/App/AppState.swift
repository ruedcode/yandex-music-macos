//
//  AppState.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

struct AppState {
    var auth: AuthState = AuthState.unauthorized
    var section: SectionState = SectionState()
    var track: TrackState = TrackState()
}
