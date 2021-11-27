//
//  PlayerViewView.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import SwiftUI

struct PlayerView: View {
    let height: CGFloat = 40
    let padding: CGFloat = 8
    var halfPadding: CGFloat {
        padding / 2
    }
    var doublePadding: CGFloat {
        padding * 2
    }
    private let imageUrl = URL(string: "https://picsum.photos/200")

    var body: some View {
        HStack {
            HStack(spacing: 24) {
                PlayerButtonView(imageName: "Play")
                PlayerButtonView(imageName: "Next")
            }
            .padding([.leading, .trailing], doublePadding)
            .frame(height: height / 2)
            AsyncImage(url: imageUrl) { image in
                image.resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .clipped()
            } placeholder: {
                ProgressView()
            }.padding([.all], halfPadding)
            VStack(alignment: .leading) {
                Text("Some text1").font(.headline)
                Text("Some text2 ").font(.caption)
            }
            HStack(spacing: 24) {
                PlayerButtonView(imageName: "Like")
            }
            .frame(height: height / 2)
        }.frame(height: height)
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView()
    }
}
