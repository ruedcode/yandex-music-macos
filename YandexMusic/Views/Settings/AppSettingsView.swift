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
    @State private var showCurrentTrackAlert = SettingsStorage.shared.showCurrentTrackAlert

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
            Spacer(minLength: 20)
            Divider()
            Spacer(minLength: 20)
            Toggle("player-settings-show-notifications".localized, isOn: $showCurrentTrackAlert)
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
