//
//  SettingsView.swift
//  YandexMusic
//
//  Created by Mike Price on 13.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import SwiftUI

struct SettingsView: View {

    @EnvironmentObject var store: Store<AppState, AppAction>
    @State private var selectedAppIconMode = SettingsStorage.shared.appIconMode

    var body: some View {
        VStack(spacing: 15) {
            Text("other-settings")
                .font(.title)
                .padding(.bottom, 10)

            VStack(alignment: .leading) {
                Text("app-icon-picker")
                Picker(selection: $selectedAppIconMode, label: EmptyView()) {
                    ForEach(AppIconMode.allCases, id: \.self) {
                        Text($0.title.localized)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: selectedAppIconMode) { newValue in
                    guard let delegate = NSApp.delegate as? AppDelegate else { return }
                    delegate.changeIcons(mode: newValue)
                }
            }
        }
        .padding()
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
