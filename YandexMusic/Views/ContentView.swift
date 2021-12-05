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

    var body: some View {
        VStack(alignment: .leading) {

            LazyVGrid(columns: columns(for: store.state.collection.stations), spacing: 20) {
                ForEach(store.state.collection.stations, id: \.self) { item in
                    Button(action: {
                        store.send(CollectionAction.select(item, andPlay: true))
                    }) {
                        VStack {
                            CustomView {
                                AsyncImage(url: URL(string: item.image)) { image in
                                    image.resizable()
                                        .aspectRatio(1, contentMode: .fit)
                                        .clipped()
                                        .frame(maxWidth: 50, maxHeight: 50)
                                } placeholder: {
                                    ProgressView()
                                }
                                .padding(8)
                            }
                            .background(
                                Color(nsColor: hexStringToColor(hex: item.color))
                            )
                            .clipShape(Circle())
                            Text(item.name)
                                .font(.subheadline)
                        }
                    }.buttonStyle(PlainButtonStyle())
                }
            }
            .padding([.leading, .trailing], 8)
            .padding(.top, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)


            ProgressView(
                "",
                value: store.state.track.currentTime,
                total: store.state.track.totalTime
            )
                .padding([.leading, .trailing], 8)
                .scaleEffect(x: 1, y: 0.5, anchor: .center)
                .labelsHidden()
                .tint(Constants.Common.primary)

            PlayerView().padding(.bottom, 8).padding([.leading, .trailing], 8)
            Spacer()
        }
    }

    private func columns(for stations: [Station]) -> [GridItem] {
        return stations.map { _ in GridItem(.flexible()) }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
