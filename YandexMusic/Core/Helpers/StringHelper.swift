//
//  StringHelper.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 03.09.2023.
//  Copyright © 2023 Eugene Kalyada. All rights reserved.
//

import Foundation

extension String {

    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }

    func format(from dict: [String: Any]) -> String {
        var tmp = self
        dict.enumerated().forEach {
            tmp = tmp.replacingOccurrences(of: "{\($0.element.key)}", with: String(describing: $0.element.value))
        }
        return tmp
    }
}
