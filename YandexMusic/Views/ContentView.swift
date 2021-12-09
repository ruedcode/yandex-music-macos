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
        return VStack(alignment: .leading) {

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
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
