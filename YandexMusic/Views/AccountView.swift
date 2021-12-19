//
//  AccountView.swift
//  YandexMusic
//
//  Created by Mike Price on 13.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import SwiftUI

struct AccountView: View {

    @EnvironmentObject var store: Store<AppState, AppAction>
    @State private var showingLogoutAlert = false

    var body: some View {
        HStack {
            AsyncImage(url: store.state.auth.avatarURL) { image in
                image.resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(Circle())
                    .clipped()
            } placeholder: {
                ProgressView()
            }

            Menu(store.state.auth.userName) {
                Button {
                    SettingsView()
                        .environmentObject(store)
                        .frame(width: 500, height: 150)
                        .openInWindow(title: "settings-title", sender: self)
                } label: {
                    Text("settings-title")
                        .frame(minWidth: 100, maxWidth: .infinity, minHeight: 44)
                }

                Button {
                    showingLogoutAlert = true
                } label: {
                    Text("logout-title")
                        .frame(minWidth: 100, maxWidth: .infinity, minHeight: 44)
                }

                Button {
                    NSApp.terminate(self)
                } label: {
                    Text("quit")
                        .frame(minWidth: 100, maxWidth: .infinity, minHeight: 44)
                }
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
            .alert(isPresented: $showingLogoutAlert) {
                Alert(
                    title: Text("logout-title"),
                    message: Text("logout-message"),
                    primaryButton: .destructive(
                        Text("logout-accept"),
                        action: {
                            store.send(AuthAction.logout)
                        }),
                    secondaryButton: .cancel()
                )
            }
        }
    }

}

extension View {
    func inExpandingRectangle() -> some View {
        ZStack {
            Rectangle()
                .fill(Color.clear)
            self
        }
    }
}
