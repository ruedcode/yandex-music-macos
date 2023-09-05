//
//  UrlHelper.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 28.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

func link(from path: String) -> String {
    let size = [
        Int(Constants.Common.imageSize.width).description,
        Int(Constants.Common.imageSize.height).description
    ].joined(separator: "x")
    return "https://" + path.replacingOccurrences(of: "%%", with: size)
}
