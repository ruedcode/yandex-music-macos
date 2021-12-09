//
//  StationView.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 05.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import SwiftUI

struct StationView: View {
    let isPlaying: Bool
    let image: URL?
    let color: Color
    let text: String

    @State private var isAnimated: Bool = false
    @EnvironmentObject var store: Store<AppState, AppAction>

    var body: some View {
        VStack {
            CustomView {
                AsyncImage(url: image) { image in
                    image.resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .clipped()
                        .frame(maxWidth: 50, maxHeight: 50)
                } placeholder: {
                    ProgressView()
                }
                .padding(8)
            }
            .background(color)
            .clipShape(Circle())
            .scaleEffect(isAnimated ? 0.8 : 1)
            .animation(isPlaying
                       ? .linear(duration: 0.7).repeatForever(autoreverses: true)
                       : .default,
                       value: isAnimated
            )
            .onReceive(store.$state) { state in
                if !isAnimated && isPlaying {
                    isAnimated = true
                }
                else if isAnimated && !isPlaying {
                    isAnimated = false
                }
            }
            Text(text)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .frame(height: 28, alignment: .top)
        }
    }
}

struct StationView_Previews: PreviewProvider {
    static var previews: some View {
        StationView(
            isPlaying: true,
            image: URL(string: "https://avatars.yandex.net/get-music-content/5234847/3155f261.a.17041333-1/400x400"),
            color: .red,
            text: "test Station"
        )
    }
}
