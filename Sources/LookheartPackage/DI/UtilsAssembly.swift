//
//  File.swift
//  
//
//  Created by KHJ on 10/29/24.
//

import Foundation
import Swinject

class UtilsAssembly: LookHeartAssembly {
    func assemble(container: Container) {
        // dateTime
        container.register(MyDateTime.self) { _ in
            return MyDateTime.shared
        }

        // keycahin
        container.register(Keychain.self) { _ in
            return Keychain.shared
        }
        
        // ui
        container.register(UIFactory.self) { _ in
            return UIFactory.shared
        }
    }
}
