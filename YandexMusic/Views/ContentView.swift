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

                AsyncImage(url: store.state.auth.avatarURL) { image in
                    image.resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .clipShape(Circle())
                        .clipped()
                } placeholder: {
                    ProgressView()
                }

                Text(store.state.auth.userName)

                PlayerButtonView(imageName: "rectangle.portrait.and.arrow.right", imageSize: .small) {
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

            StationListView()


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
