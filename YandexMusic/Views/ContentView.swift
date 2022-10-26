//
//  ContentView.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 12/18/19.
//  Copyright © 2019 Eugene Kalyada. All rights reserved.
//

import SwiftUI

struct ContentView: View {

    @EnvironmentObject var store: Store<AppState, AppAction>
    @State private var showingLogoutAlert = false
    @State private var showingMorePopover = false

    var body: some View {
        return VStack(alignment: .leading) {
            makeMenu()

            Divider()
                .padding([.leading, .trailing], 8)

            StationListView()

            TrackProgressView()

            PlayerView()

        }.frame(minWidth: 450)
    }

    private func makeMenu() -> some View {
        HStack {
            Menu(store.state.station.stationGroup?.name ?? "") {
                ForEach(store.state.station.groups, id: \.self) { item in
                    Button(action: {
                        store.send(StationAction.selectGroup(item, andPlay: true))
                    }) {
                        Text(item.name)
                    }
                }
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
            Spacer()

            AccountView()
        }
        .padding([.leading, .trailing], 12)
        .padding(.top, 10)
        .frame(height: 30)
    }
}
