//
//  AboutSettingsView.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 15.10.2022.
//  Copyright © 2022 Eugene Kalyada. All rights reserved.
//

import SwiftUI

struct AboutSettingsView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(nsImage: NSImage(named: "AppIcon")!)

            Text("\(Bundle.main.appName)")
                .font(.system(size: 20, weight: .bold))

            Text("Version: \(Bundle.main.appVersionLong) (\(Bundle.main.appBuild)) ")

            Text(Bundle.main.copyright)
                .font(.system(size: 10, weight: .thin))
                .multilineTextAlignment(.center)
        }.padding()
    }
}

fileprivate extension Bundle {
    var appName: String {
        getInfo("CFBundleName")
    }

    var copyright: String {
        getInfo("NSHumanReadableCopyright").replacingOccurrences(of: "\\\\n", with: "\n")
    }

    var appBuild: String { getInfo("CFBundleVersion") }
    var appVersionLong: String { getInfo("CFBundleShortVersionString") }

    func getInfo(_ str: String) -> String { infoDictionary?[str] as? String ?? "⚠️" }
}

struct AboutSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AboutSettingsView()
    }
}
