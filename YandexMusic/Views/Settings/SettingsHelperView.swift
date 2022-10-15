//
//  SettingsHelperView.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 15.10.2022.
//  Copyright © 2022 Eugene Kalyada. All rights reserved.
//

import SwiftUI

protocol PickerItem: Equatable, Identifiable, Hashable {
    var title: String { get }
}

struct SettingsPicker<Item>: View where Item: PickerItem {

    let title: String
    let items: [Item]
    @State var selection: Item
    let onChange: (Item) -> Void

    var body: some View {
        Text(title.localized)
        Picker(selection: $selection, label: EmptyView()) {
            ForEach(items) { item in
                Text(item.title.localized)
                    .tag(item)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: selection, perform: onChange)
    }
}

struct SettingsListContainer<Content>: View where Content: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading) {
            content()
            Spacer(minLength: 1)
        }.padding()
    }
}
