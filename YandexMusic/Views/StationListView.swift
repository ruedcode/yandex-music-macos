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
        ScrollView {
            LazyVGrid(columns: columns(for: store.state.station.stations), spacing: 20) {
                ForEach(store.state.station.stations, id: \.self) { item in
                    Button(action: {
                        store.send(StationAction.select(item, andPlay: true))
                    }) {
                        StationView(
                            isPlaying: item == store.state.station.station && store.state.track.isPlaying,
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
        .frame(minHeight: store.state.station.stations.count > 4 ? 250 : 100)
    }

    private func columns(for stations: [Station]) -> [GridItem] {
        Array(repeating: .init(.flexible()), count: min(stations.count, 4))
    }
}

struct StationListView_Previews: PreviewProvider {
    static var previews: some View {
        StationListView()
    }
}
