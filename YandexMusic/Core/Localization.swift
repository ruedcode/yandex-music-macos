//
//  Localization.swift
//  YandexMusic
//
//  Created by Mike Price on 09.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

extension String {
    /// Take current string as a key and return localized string
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
