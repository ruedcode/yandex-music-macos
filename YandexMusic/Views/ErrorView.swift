//
//  ErrorView.swift
//  YandexMusic
//
//  Created by Mike Price on 13.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import SwiftUI

struct ErrorView: View {
    private let errorMessage: String
    private let buttonText: String
    private let repeatAction: (() -> Void)?

    init(_ errorMessage: String = "common-error",
         buttonText: String = "repeat-bt-error",
         repeatAction: (() -> Void)? = nil) {
        self.errorMessage = errorMessage
        self.buttonText = buttonText
        self.repeatAction = repeatAction
    }

    private var content: some View {
        CustomView {
            Text(errorMessage.localized)
            if let repeatAction = repeatAction {
                Button(buttonText.localized, action: repeatAction)
            }
        }
    }

    var body: some View {
        GeometryReader { g in
            HStack {
                Spacer()
                if g.size.height > 50 {
                    VStack {
                        Spacer()
                        content
                        Spacer()
                    }
                } else {
                    content
                }
                Spacer()
            }
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView()
            .frame(width: 400, height: 200)
    }
}
