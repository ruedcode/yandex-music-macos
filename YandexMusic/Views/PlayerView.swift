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
    @State var isShareMode: Bool = false
    @State var isNexteMode: Bool = false
    @State private var showingVolumePopover = false
    @State private var soundLevel: Float = AudioProvider.instance.volume
    @State private var showingPlayerSettingsPopover = false

    private var soundIconName: String {
        switch soundLevel {
        case 0: return "speaker.slash"
        case 0...0.3: return "speaker"
        case 0.3...0.7: return "speaker.wave.1"
        default: return "speaker.wave.2"
        }
    }

    private var shareIcon: String {
        isShareMode
        ? "personalhotspot"
        : "square.and.arrow.up"
    }

    private var playIcon: String {
        store.state.track.isPlaying
        ? "pause"
        : "play.fill"
    }

    private var likeIcon: String {
        store.state.track.current?.liked == true
        ? "heart.fill"
        : "heart"
    }

    var body: some View {
        if case let .error(error) = store.state.track.loadingState {
            ErrorView(error.text,
                      buttonText: error.button,
                      repeatAction: {
                store.send(error.action)
            })
            .frame(height: 40)
        } else {
            HStack {
                makeLeftButtons()
                
                makeTrackInfo()
                
                Spacer()
                
                makeRightButtons()
                
            }.frame(height: constants.height)
                .padding(.bottom, 8)
                .padding([.leading, .trailing], 8)
        }
    }

    private func makeTrackInfo() -> some View {
        HStack {
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
                    .frame(alignment: .leading)
                Text(store.state.track.current?.artist.name ?? "")
                    .font(.caption)
                    .help(store.state.track.current?.artist.name ?? "")
                    .frame(alignment: .leading)
            }
        }
    }

    private func makeLeftButtons() -> some View {
        HStack {
            PlayerButtonView(imageName: playIcon, imageSize: .large) {
                if store.state.track.isPlaying {
                    store.send(TrackAction.pause)
                }
                else {
                    store.send(TrackAction.play)
                }
            }
            .help(store.state.track.isPlaying ? "help-pause" : "help-play")

            PlayerButtonView(imageName: isNexteMode ? "forward.fill" : "forward") {
                isNexteMode = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isNexteMode = false
                }
                store.send(TrackAction.playNext)
            }
            .padding([.top, .bottom], constants.padding)
            .help(store.state.track.next?.fullName ?? "help-next-song")
            .padding([.trailing], constants.padding)
        }
    }

    private func makeRightButtons() -> some View {
        HStack {
            PlayerButtonView(imageName: "music.note.list") {
                showingPlayerSettingsPopover = true
            }
            .popover(isPresented: $showingPlayerSettingsPopover) {
                StreamSettingsView()
            }

            PlayerButtonView(imageName: likeIcon) {
                store.send(TrackAction.toggleLike)
            }.help(store.state.track.current?.liked == false ? "help-favourite-add" : "help-favourite-remove")

            PlayerButtonView(imageName: shareIcon) {
                store.send(TrackAction.share)
                isShareMode = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    isShareMode = false
                }
            }.help("help-share")

            PlayerButtonView(imageName: "multiply.circle") {
                store.send(TrackAction.ban)
            }.help("help-block")

            PlayerButtonView(imageName: soundIconName) {
                showingVolumePopover = true
            }.help("help-volume")
                .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .global).onEnded({
                    let change = Float(($0.location.x - $0.startLocation.x) / 200)
                    let old = AudioProvider.instance.volume
                    let new = min(max(old + change, 0), 1)
                    soundLevel = new
                    AudioProvider.instance.volume = new
                }))
                .popover(isPresented: $showingVolumePopover) {
                    Slider(value: $soundLevel, in: 0...1)
                        .onChange(of: soundLevel, perform: { newValue in
                            AudioProvider.instance.volume = newValue
                        })
                        .frame(minWidth: 100)
                        .padding()
                }
        }
        .frame(alignment: .trailing)
        .padding([.top, .bottom, .trailing], constants.padding)
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
