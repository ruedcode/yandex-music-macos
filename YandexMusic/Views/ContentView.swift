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
    @State private var showingMorePopover = false

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

                AccountView()
            }
            .padding([.leading, .trailing], 12)
            .padding(.top, 10)
            .frame(height: 30)

            Divider()
                .padding([.leading, .trailing], 8)

            if let error = store.state.station.error {
                ErrorView(error.text,
                          buttonText: error.button,
                          repeatAction: {
                    store.send(error.action)
                })
                .frame(height: 40)
            } else {
                StationListView()
            }

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
                }
            }
            .padding([.leading, .trailing], 8)
            .frame(height: 32)

            if case let .error(error) = store.state.track.loadingState {
                ErrorView(error.text,
                          buttonText: error.button,
                          repeatAction: {
                    store.send(error.action)
                })
                .frame(height: 40)
            } else {
                PlayerView()
                    .padding(.bottom, 8)
                    .padding([.leading, .trailing], 8)
            }

        }.frame(minWidth: 450)
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
