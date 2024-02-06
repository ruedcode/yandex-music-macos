//
//  TrackProgressView.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 26.10.2022.
//  Copyright © 2022 Eugene Kalyada. All rights reserved.
//

import SwiftUI

struct TrackProgressView: View {

    @EnvironmentObject var store: Store<AppState, AppAction>

    var body: some View {
        GeometryReader { (geometry) in
            ProgressView(
                "",
                value: store.state.track.totalTime > 0
                ? store.state.track.currentTime
                : 0,
                total: store.state.track.totalTime
            )
            .labelsHidden()
            .progressViewStyle(LinearProgressViewStyle(tint: Constants.Common.primary))
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        let progress = value.location.x / geometry.size.width
                        store.send(TrackAction.seek(to: progress))
                    }
            )
            if store.state.track.current != nil {
                HStack {
                    if store.state.track.isPlaying || store.state.track.currentTime > 0 {
                        makeTimeLabel(for: store.state.track.currentTime)
                    }
                    Spacer()
                    if store.state.track.totalTime > 0 {
                        makeTimeLabel(for: store.state.track.totalTime)
                    }
                }
                .padding([.top], 16)
            }
        }
        .padding([.leading, .trailing], 8)
        .frame(height: 32)
    }

    private func makeTimeLabel(for value: Double) -> some View {
        Text(time(from: value))
            .font(.footnote)
            .opacity(0.5)
    }

    private func time(from value: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: TimeInterval(value)) ?? ""
    }
}
