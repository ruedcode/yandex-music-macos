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
    @State private var selectedMoodEnergy: PlayerSettingsMood = .all
    @State private var selectedDiversity: PlayerSettingsDiversity = .default
    @State private var selectedLanguage: PlayerSettingsLanguage = .any

    var body: some View {
        VStack(spacing: 15) {

            Text("player-settings-title")
                .font(.title)
                .padding(.bottom, 10)

            ZStack {
                VStack(alignment: .leading) {

                    Text("player-settings-mood-energy")
                    Picker(selection: $selectedMoodEnergy, label: EmptyView()) {
                        ForEach(PlayerSettingsMood.allCases) { item in
                            Text(item.title)
                                .tag(item)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedMoodEnergy) { newValue in
                        store.send(PlayerSettingsAction.updateMoodEnergy(newValue))
                    }
                    .padding(.bottom, 10)

                    Text("player-settings-diversity")
                    Picker(selection: $selectedDiversity, label: EmptyView()) {
                        ForEach(PlayerSettingsDiversity.allCases) { item in
                            Text(item.title)
                                .tag(item)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedDiversity) { newValue in
                        store.send(PlayerSettingsAction.updateDiversity(newValue))
                    }
                    .padding(.bottom, 10)

                    Text("player-settings-language")
                    Picker(selection: $selectedLanguage, label: EmptyView()) {
                        ForEach(PlayerSettingsLanguage.allCases) { item in
                            Text(item.title)
                                .tag(item)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedLanguage) { newValue in
                        store.send(PlayerSettingsAction.updateLanguage(newValue))
                    }
                    .padding(.bottom, 10)
                }
                .onReceive(store.$state) { state in
                    if state.playerSettings.language != selectedLanguage {
                        selectedLanguage = state.playerSettings.language
                    }
                    if state.playerSettings.diversity != selectedDiversity {
                        selectedDiversity = state.playerSettings.diversity
                    }
                    if state.playerSettings.moodEnergy != selectedMoodEnergy {
                        selectedMoodEnergy = state.playerSettings.moodEnergy
                    }
                }
                .onAppear {
                    store.send(PlayerSettingsAction.fetch)
                }

                if store.state.playerSettings.isLoading {
                    Color.black.opacity(0.1)
                    ProgressView()
                }

                if let error = store.state.playerSettings.error {
                    ErrorView(error.text,
                              buttonText: error.button,
                              repeatAction: {
                        store.send(error.action)
                    })
                }
            }

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

extension PlayerSettingsMood {
    var title: String {
        switch self {
        case .active: return "player-settings-active".localized
        case .fun: return "player-settings-fun".localized
        case .calm: return "player-settings-calm".localized
        case .sad: return "player-settings-sad".localized
        case .all: return "player-settings-all".localized
        }
    }
}

extension PlayerSettingsDiversity {
    var title: String {
        switch self {
        case .favorite: return "player-settings-favorite".localized
        case .discover: return "player-settings-discover".localized
        case .popular: return "player-settings-popular".localized
        case .default: return "player-settings-default".localized
        }
    }
}

extension PlayerSettingsLanguage {
    var title: String {
        switch self {
        case .russian: return "player-settings-russian".localized
        case .notRussian: return "player-settings-not-russian".localized
        case .any: return "player-settings-any".localized
        }
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
