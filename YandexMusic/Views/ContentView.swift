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
                    Alert(title: Text("logout-title"),
                          message: Text("logout-message"),
                          primaryButton: .destructive(Text("logout-accept"), action: { store.send(AuthAction.logout) }),
                          secondaryButton: .cancel()
                    )
                  }
                .buttonStyle(PlainButtonStyle())
                .help("logout-title")
            }
            .padding([.leading, .trailing], 12)
            .padding(.top, 10)
            .frame(height: 30)

            Divider()
                .padding([.leading, .trailing], 8)

            LazyVGrid(columns: columns(for: store.state.section.stations), spacing: 20) {
                ForEach(store.state.section.stations, id: \.self) { item in
                    Button(action: {
                        store.send(SectionAction.select(item, andPlay: true))
                    }) {
                        StationView(
                            isPlaying: item == store.state.section.selected && store.state.track.isPlaying,
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
