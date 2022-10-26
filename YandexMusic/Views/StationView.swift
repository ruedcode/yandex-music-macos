//
//  StationView.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 05.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import SwiftUI

struct StationView: View {
    let image: URL?
    let color: Color
    let text: String

    private let animation = Animation.linear(duration: 0.7).repeatForever(autoreverses: true)

    @State private var isAnimated: Bool = false
    @EnvironmentObject var store: Store<AppState, AppAction>

    var body: some View {
        VStack {
            CustomView {
                AsyncImage(url: image) { image in
                    image.resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .clipped()
                } placeholder: {
                    ProgressView()
                }
                .padding(8)
            }
            .frame(width: 66, height: 66)
            .background(color)
            .clipShape(Circle())
            .scaleEffect(isAnimated ? 0.8 : 1)
            .animation(isAnimated
                       ? animation
                       : .default,
                       value: isAnimated
            )
            .onReceive(store.$state
                .map {(
                    $0.track.isPlaying,
                    $0.station.station?.name ?? "",
                    $0.station.stationGroup?.id ?? ""
                )}
                .removeDuplicates(by: {
                    return $0 == $1
                })
            ) {
                guard $0.1 == text else {
                    isAnimated = false
                    return
                }
                isAnimated = $0.0
            }
            .onAppear {
                guard isAnimated else {
                    isAnimated = false
                    return
                }
                isAnimated = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isAnimated = true
                }
            }

            Text(text)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .frame(height: 28, alignment: .top)
        }
    }
}
