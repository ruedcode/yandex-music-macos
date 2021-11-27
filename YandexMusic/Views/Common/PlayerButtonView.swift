//
//  PlayerButtonView.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import SwiftUI

struct PlayerButtonView: View {

    private let imageName: String
    private let buttonAction: () -> Void

    init(imageName: String, action: @escaping () -> Void = {}) {
        self.imageName = imageName
        self.buttonAction = action
    }

    var body: some View {
        Button(action: buttonAction) {
            Image(imageName)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
        }
        .tint(Color.gray)
        .buttonStyle(PlainButtonStyle())
    }
}

struct PlayerButtonView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerButtonView(imageName: "Play")
    }
}
