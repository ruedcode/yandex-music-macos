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

            Divider()
                .padding([.leading, .trailing], 8)

            if store.state.station.hasError {
                ErrorView {
                    store.send(StationAction.fetch)
                }
                .frame(minHeight: 100)
            } else {
                StationListView()
            }

            ProgressView(
                "",
                value: store.state.track.totalTime > 0
                    ? store.state.track.currentTime
                    : 0,
                total: store.state.track.totalTime
            )
                .padding([.leading, .trailing], 8)
                .scaleEffect(x: 1, y: 0.5, anchor: .center)
                .labelsHidden()
                .progressViewStyle(LinearProgressViewStyle(tint: Constants.Common.primary))

            if let error = store.state.track.error {
                ErrorView(error.text,
                          buttonText: error.button,
                          repeatAction: {
                    store.send(error.action)
                }) 
                .frame(height: 40)
            } else {
                PlayerView()
                    .padding(.bottom, 8)
                    .padding([.leading, .trailing], 8)
            }

        }.frame(minWidth: 400)
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
