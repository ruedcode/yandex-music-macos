//
//  PlayerViewView.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import SwiftUI

struct PlayerView: View {
    private let constants = Constants()

    private let imageUrl = URL(string: "https://picsum.photos/200")

    @State private var isPlaying = false
    @State private var isLiked = false

    var body: some View {
        HStack {
            PlayerButtonView(imageName: isPlaying ? "Pause" : "Play") {
                isPlaying = !isPlaying
            }

            PlayerButtonView(imageName: "Next")
            .padding(.leading, constants.padding)
            .padding([.top, .bottom], constants.padding)

            AsyncImage(url: imageUrl) { image in
                image.resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .clipped()
            } placeholder: {
                ProgressView()
            }

            VStack(alignment: .leading) {
                Text("Daylight").font(.headline)
                Text("Young Guns").font(.caption)
            }

            PlayerButtonView(imageName: isLiked ? "Liked" : "Like") {
                isLiked = !isLiked
            }
            .padding(.leading, constants.padding)
            .padding([.top, .bottom], constants.padding)

            PlayerButtonView(imageName: "Block") {
            }
            .padding(.leading, constants.padding)
            .padding([.top, .bottom], constants.padding)

            PlayerButtonView(imageName: "Share") {
            }
            .padding([.leading, .trailing], constants.padding)
            .padding([.top, .bottom], constants.padding)

        }.frame(height: constants.height)
    }
}

private extension PlayerView {
    struct Constants {
        let height: CGFloat = 40
        let padding: CGFloat = 8
        var halfPadding: CGFloat {
            padding / 2
        }
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView()
    }
}
