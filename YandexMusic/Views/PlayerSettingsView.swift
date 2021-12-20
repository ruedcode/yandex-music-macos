//
//  PlayerSettingsView.swift
//  YandexMusic
//
//  Created by Mike Price on 19.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import SwiftUI

struct PlayerSettingsView: View {

    @State private var selectedMoodEnergy: PlayerSettingsMood = .all
    @State private var selectedDiversity: PlayerSettingsDiversity = .default
    @State private var selectedLanguage: PlayerSettingsLanguage = .any

    @EnvironmentObject var store: Store<AppState, AppAction>

    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                Text(store.state.station.station?.name ?? "")
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .center)

                Divider()

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
                ErrorView(
                    error.text,
                    buttonText: error.button,
                    repeatAction: {
                        store.send(error.action)
                    }
                )
            }
        }
            .padding()
    }

}

// MARK: - Localizations

private extension PlayerSettingsMood {
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

private extension PlayerSettingsDiversity {
    var title: String {
        switch self {
        case .favorite: return "player-settings-favorite".localized
        case .discover: return "player-settings-discover".localized
        case .popular: return "player-settings-popular".localized
        case .default: return "player-settings-default".localized
        }
    }
}

private extension PlayerSettingsLanguage {
    var title: String {
        switch self {
        case .russian: return "player-settings-russian".localized
        case .notRussian: return "player-settings-not-russian".localized
        case .any: return "player-settings-any".localized
        }
    }
}
