//
//  SettingsView.swift
//  YandexMusic
//
//  Created by Mike Price on 13.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import SwiftUI

struct SettingsView: View {

    @State private var selectedAppIconMode = SettingsStorage.shared.appIconMode

    var body: some View {
        VStack {
            Picker("app-icon-picker", selection: $selectedAppIconMode) {
                ForEach(AppIconMode.allCases, id: \.self) {
                    Text($0.title.localized)
                }
            }.onChange(of: selectedAppIconMode) { newValue in
                guard let delegate = NSApp.delegate as? AppDelegate else { return }
                delegate.changeIcons(mode: newValue)
            }

            Spacer()
        }.padding()
    }
}

private extension AppIconMode {
    var title: String {
        switch self {
        case .both: return "app-icon-both"
//        case .dock: return "app-icon-dock"
        case .context: return "app-icon-context"
        }
    }
}
