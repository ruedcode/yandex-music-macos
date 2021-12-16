//
//  DockView.swift
//  YandexMusic
//
//  Created by Mike Price on 13.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import SwiftUI

struct DockView: View {
    @EnvironmentObject
    var store: Store<AppState, AppAction>
    var onUpdate: () -> Void

    @State private var lastPhase: AsyncImagePhase?
    @State private var lastImage: Image?

    var body: some View {
        AsyncImage(url: store.state.track.current?.album.image, content: makeButtonLabel)
    }

    private func makeButtonLabel(_ phase: AsyncImagePhase) -> AnyView {
        defer {
            if lastPhase != phase {
                DispatchQueue.main.async {
                    lastPhase = phase
                }
                onUpdate()
            }
        }
        switch phase {
        case .empty:
            return AnyView(ProgressView())
        case .success(let image):
            return AnyView(
                image
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .cornerRadius(16)
                    .overlay(DockBadgeView())
                    .clipped()
            )
        case .failure:
            return AnyView(Image(nsImage: NSImage(named: "AppIcon")!))
        }
    }
}

private struct DockBadgeView: View {
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.clear
            Image(nsImage: NSImage(named: "AppIcon")!)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .clipped()
                .frame(width: 50, height: 50)
                .alignmentGuide(.top) { $0[.top] }
                .alignmentGuide(.trailing) { $0[.trailing] }
        }
    }
}

extension AsyncImagePhase: Equatable {
    public static func == (lhs: AsyncImagePhase, rhs: AsyncImagePhase) -> Bool {
        switch (lhs, rhs) {
        case (.empty, .empty):
            return true
        case (.failure, .failure):
            return true
        case (.success(let lhsImage), .success(let rhsImage)):
            return lhsImage == rhsImage
        default:
            return false
        }
    }
}
