//
//  ContentView.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 12/18/19.
//  Copyright © 2019 Eugene Kalyada. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    let data = [
        "https://avatars.yandex.net/get-music-misc/70850/rotor-personal-station-icon/100x100",
        "https://avatars.yandex.net/get-music-misc/34161/rotor-epoch-the-greatest-hits-icon/100x100",
        "https://avatars.yandex.net/get-music-misc/34161/rotor-genre-metal-icon/100x100",
        "https://avatars.yandex.net/get-music-misc/34161/rotor-genre-alternative-icon/100x100"
    ]

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(alignment: .leading) {

            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(data, id: \.self) { item in
                    AsyncImage(url: URL(string: item)) { image in
                        image.resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .clipped()
                            .background(Color.red)
                    } placeholder: {
                        ProgressView()
                    }
                    .clipShape(Circle())
                }
            }
            .padding([.leading, .trailing], 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider().padding([.leading, .trailing], 8)

            PlayerView().padding(.bottom, 8).padding([.leading, .trailing], 8)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
