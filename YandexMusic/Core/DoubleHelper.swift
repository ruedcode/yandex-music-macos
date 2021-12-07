//
//  DoubleHelper.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 08.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

extension Double {
    var asInt: Int {
        guard !(self.isNaN || self.isInfinite) else {
            return 0
        }
        return Int(self)
    }
}
