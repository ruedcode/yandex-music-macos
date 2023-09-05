//
//  Assemblyregistrator.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 03.09.2023.
//  Copyright © 2023 Eugene Kalyada. All rights reserved.
//

import Foundation

final class AssemblyRegistrator {
    static var instance = AssemblyRegistrator()
    
    let assembly = Assembly()

    private init() {
        assembly.register { _ -> AuthProvider in 
            AuthProviderImpl()
        }

        assembly.register { _ -> Analytics in
            AnalyticsImpl()
        }

    }
}
