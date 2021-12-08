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

    var body: some View {
        return VStack(alignment: .leading) {

            HStack {
                Spacer()

                PlayerButtonView(imageName: "Logout") {
                    showingLogoutAlert = true
                }
                .alert(isPresented: $showingLogoutAlert) {
                    Alert(title: Text("Logout"),
                          message: Text("Do you really want to logout?"),
                          primaryButton: .destructive(Text("Logout"), action: { store.send(AuthAction.logout) }),
                          secondaryButton: .cancel()
                    )
                  }
                .buttonStyle(PlainButtonStyle())
                .help("Logout")
            }
            .padding([.leading, .trailing], 12)
            .padding(.top, 10)
            .frame(height: 30)

            Divider()
                .padding([.leading, .trailing], 8)

            LazyVGrid(columns: columns(for: store.state.collection.stations), spacing: 20) {
                ForEach(store.state.collection.stations, id: \.self) { item in
                    Button(action: {
                        store.send(CollectionAction.select(item, andPlay: true))
                    }) {
                        StationView(
                            isPlaying: item == store.state.collection.selected && store.state.track.isPlaying,
                            image: URL(string: item.image),
                            color: hexStringToColor(hex: item.color),
                            text: item.name
                        )
                    }.buttonStyle(PlainButtonStyle())
                }
            }
            .padding([.leading, .trailing], 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)


            ProgressView(
                "",
                value: store.state.track.currentTime,
                total: store.state.track.totalTime
            )
                .padding([.leading, .trailing], 8)
                .scaleEffect(x: 1, y: 0.5, anchor: .center)
                .labelsHidden()
                .progressViewStyle(LinearProgressViewStyle(tint: Constants.Common.primary))

            PlayerView().padding(.bottom, 8).padding([.leading, .trailing], 8)
            Spacer()
        }.frame(minWidth: 380)
    }

    private func columns(for stations: [Station]) -> [GridItem] {
        return stations.map { _ in GridItem(.flexible()) }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(Store<AppState, AppAction>(
            initialState: .init(),
            appReducer: appReducer
        ))
    }
}
