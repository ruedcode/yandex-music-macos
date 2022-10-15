//
//  AppSettingsView.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 15.10.2022.
//  Copyright © 2022 Eugene Kalyada. All rights reserved.
//

import SwiftUI

struct AppSettingsView: View {

    @EnvironmentObject var store: Store<AppState, AppAction>
    @State private var selectedAppIconMode = SettingsStorage.shared.appIconMode

    var body: some View {
        SettingsListContainer {
            SettingsPicker(
                title: "app-icon-picker",
                items: AppIconMode.allCases,
                selection: selectedAppIconMode
            ) {
                guard let delegate = NSApp.delegate as? AppDelegate else { return }
                delegate.changeIcons(mode: $0)
            }
        }
    }
}

extension AppIconMode: PickerItem {
    var id: String {
        self.rawValue
    }

    var title: String {
        switch self {
        case .both: return "app-icon-both"
        case .context: return "app-icon-context"
        }
    }
}
