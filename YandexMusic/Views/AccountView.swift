//
//  AccountView.swift
//  YandexMusic
//
//  Created by Mike Price on 13.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import SwiftUI

/*


 PlayerButtonView(imageName: "rectangle.portrait.and.arrow.right", imageSize: .small) {
     showingLogoutAlert = true
 }
 .alert(isPresented: $showingLogoutAlert) {
     Alert(title: Text("logout-title"),
           message: Text("logout-message"),
           primaryButton: .destructive(Text("logout-accept"), action: { store.send(AuthAction.logout) }),
           secondaryButton: .cancel()
     )
   }
 .buttonStyle(PlainButtonStyle())
 .help("logout-title")
 */

struct AccountView: View {

    @EnvironmentObject var store: Store<AppState, AppAction>
    @State private var showingLogoutAlert = false
    @State private var showingMorePopover = false

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

            Button(action: {
                showingMorePopover = true
            }, label: {
                Text(store.state.auth.userName)
                    .bold()
            })
                .buttonStyle(.borderless)
                .popover(isPresented: $showingMorePopover) {
                    VStack {
                        Button {
                            SettingsView()
                                .frame(width: 500, height: 500)
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
                        .alert(isPresented: $showingLogoutAlert) {
                            Alert(title: Text("logout-title"),
                                  message: Text("logout-message"),
                                  primaryButton: .destructive(Text("logout-accept"), action: { store.send(AuthAction.logout) }),
                                  secondaryButton: .cancel()
                            )
                        }

                        Button {
                            NSApp.terminate(self)
                        } label: {
                            Text("quit")
                                .frame(minWidth: 100, maxWidth: .infinity, minHeight: 44)
                        }
                    }.padding()
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
