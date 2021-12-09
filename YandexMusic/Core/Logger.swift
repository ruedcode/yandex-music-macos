//
//  Logger.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 01.12.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

import Foundation

enum LogLevel: String {
    case debug = "DEBUG"
    case warn = "WARN"
    case error = "ERROR"
    case info = "INFO"
}

func log(_ error: Error, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
    log(error, level: .error, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
}

func log(_ closure: @autoclosure () -> Any?, level: LogLevel = .debug, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
    guard let closure = closure() else { return }
    NSLog(
        "[%@] %@:%@ %@ :: %@",
        level.rawValue,
        URL(string: fileName.description)?.lastPathComponent ?? "-",
        lineNumber.description,
        functionName.description,
        String(describing: closure)
    )
}

func log(_ info: String) {
    NSLog("%@", info)
}
