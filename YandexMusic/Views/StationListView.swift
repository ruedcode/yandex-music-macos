//
//  StationListView.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 09.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import SwiftUI

struct StationListView: View {

    @EnvironmentObject var store: Store<AppState, AppAction>

    var body: some View {

        if let error = store.state.station.error {
            ErrorView(error.text,
                      buttonText: error.button,
                      repeatAction: {
                store.send(error.action)
            })
            .frame(height: 40)
        } else {
            ScrollView {
                LazyVGrid(columns: columns(for: store.state.station.stations), spacing: 20) {
                    ForEach(store.state.station.stations) { item in
                        Button(action: {
                            store.send(StationAction.select(item, andPlay: true))
                        }) {
                            StationView(
                                image: URL(string: item.image),
                                color: hexStringToColor(hex: item.color),
                                text: item.name
                            )
                        }.buttonStyle(PlainButtonStyle())
                    }
                }
                .padding([.leading, .trailing], 8)
                .padding(.top, 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: store.state.station.stations.count > 4 ? 240 : 120)
        }
    }

    private func columns(for stations: [Station]) -> [GridItem] {
        Array(repeating: .init(.flexible()), count: min(stations.count, 4))
    }
}
