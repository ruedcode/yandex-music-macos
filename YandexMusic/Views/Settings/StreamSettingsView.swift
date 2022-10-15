//
//  StreamSettingsView.swift
//  YandexMusic
//
//  Created by Mike Price on 19.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import SwiftUI

struct StreamSettingsView: View {

    @State private var selectedMoodEnergy: PlayerSettingsMood = .all
    @State private var selectedDiversity: PlayerSettingsDiversity = .default
    @State private var selectedLanguage: PlayerSettingsLanguage = .any

    @EnvironmentObject var store: Store<AppState, AppAction>

    var body: some View {
        ZStack {
            if let error = store.state.playerSettings.error {
                ErrorView(
                    error.text,
                    buttonText: error.button,
                    repeatAction: {
                        store.send(error.action)
                    }
                )
            } else {

                SettingsListContainer {
                    Text(store.state.station.station?.name ?? "loading".localized)
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Divider()

                    SettingsPicker(
                        title: "player-settings-mood-energy",
                        items: PlayerSettingsMood.allCases,
                        selection: selectedMoodEnergy
                    ) {
                        store.send(PlayerSettingsAction.updateMoodEnergy($0))
                    }.padding(.bottom, 10)

                    SettingsPicker(
                        title: "player-settings-diversity",
                        items: PlayerSettingsDiversity.allCases,
                        selection: selectedDiversity
                    ) {
                        store.send(PlayerSettingsAction.updateDiversity($0))
                    }.padding(.bottom, 10)

                    SettingsPicker(
                        title: "player-settings-language",
                        items: PlayerSettingsLanguage.allCases,
                        selection: selectedLanguage
                    ) {
                        store.send(PlayerSettingsAction.updateLanguage($0))
                    }.padding(.bottom, 10)
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
            }

            if store.state.playerSettings.isLoading {
                Color.black.opacity(0.1)
                ProgressView()
            }

        }.padding()
    }

}

// MARK: - Localizations

extension PlayerSettingsMood: PickerItem {
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

extension PlayerSettingsDiversity: PickerItem {
    var title: String {
        switch self {
        case .favorite: return "player-settings-favorite".localized
        case .discover: return "player-settings-discover".localized
        case .popular: return "player-settings-popular".localized
        case .default: return "player-settings-default".localized
        }
    }
}

extension PlayerSettingsLanguage: PickerItem {
    var title: String {
        switch self {
        case .russian: return "player-settings-russian".localized
        case .notRussian: return "player-settings-not-russian".localized
        case .any: return "player-settings-any".localized
        }
    }
}
