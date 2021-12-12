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
    private let repeatAction: (() -> Void)?

    init(_ errorMessage: String = "common-error", repeatAction: (() -> Void)? = nil) {
        self.errorMessage = errorMessage
        self.repeatAction = repeatAction
    }

    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                Text(errorMessage.localized)
                if let repeatAction = repeatAction {
                    Button("repeat-bt-error", action: repeatAction)
                        .padding(.top, 5)
                }
                Spacer()
            }
            Spacer()
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView()
            .frame(width: 400, height: 200)
    }
}
