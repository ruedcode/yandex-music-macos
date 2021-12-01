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
    @EnvironmentObject var store: Store<AppState, AppAction>

    var body: some View {
        HStack {
            PlayerButtonView(imageName: store.state.track.isPlaying ? "Pause" : "Play") {
                store.send(TrackAction.togglePlay)
            }

            PlayerButtonView(imageName: "Next") {
                store.send(TrackAction.playNext)
            }
                .padding(.leading, constants.padding)
                .padding([.top, .bottom], constants.padding)
                .help(store.state.track.next?.fullName ?? "")

            AsyncImage(url: store.state.track.current?.album.image) { image in
                image.resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .clipped()
            } placeholder: {
                ProgressView()
            }
            .help(store.state.track.current?.album.name ?? "")

            VStack(alignment: .leading) {
                Text(store.state.track.current?.name ?? "")
                    .font(.headline)
                    .help(store.state.track.current?.name ?? "")
                Text(store.state.track.current?.artist.name ?? "")
                    .font(.caption)
                    .help(store.state.track.current?.artist.name ?? "")
            }

            PlayerButtonView(imageName: store.state.track.current?.liked == true ? "Liked" : "Like") {
//                isLiked = !isLiked
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
