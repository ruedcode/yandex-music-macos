//
//  PlayerButtonView.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import SwiftUI

struct PlayerButtonView: View {

    enum ImageSize {
        case `default`
        case large
        case small

        fileprivate var asFont: Font {
            switch self {
            case .default: return .system(size: 20)
            case .large: return .system(size: 36)
            case .small: return .system(size: 14)
            }
        }

        fileprivate var minSize: CGFloat {
            switch self {
            case .default: return 25
            case .large: return 44
            case .small: return 20
            }
        }
    }

    private let imageName: String
    private let imageSize: ImageSize
    private let buttonAction: () -> Void

    init(imageName: String, imageSize: ImageSize = .default, action: @escaping () -> Void = {}) {
        self.imageName = imageName
        self.imageSize = imageSize
        self.buttonAction = action
    }

    var body: some View {
        Button(action: buttonAction) {
            Image(systemName: imageName)
                .font(imageSize.asFont)
        }
        .frame(minWidth: imageSize.minSize, minHeight: imageSize.minSize)
        .foregroundColor(Color("Primary"))
        .buttonStyle(PlainButtonStyle())
    }
}

struct PlayerButtonView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerButtonView(imageName: "next")
    }
}
