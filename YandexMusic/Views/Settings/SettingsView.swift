//
//  SettingsView.swift
//  YandexMusic
//
//  Created by Mike Price on 13.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import SwiftUI

struct SettingsView: View {

    var body: some View {
        TabView {
            makeItem(with: "settings-application", view: AppSettingsView())
            makeItem(with: "settings-about", view: AboutSettingsView())
        }
        .frame(alignment: .top)
        .padding()
    }

    private func makeItem(with title: String, view: some View) -> some View {
        view.tabItem {
            Text(title.localized)
        }
    }
}
