//
//  File.swift
//  
//
//  Created by 정연호 on 10/29/24.
//

import Foundation
import Swinject

class UtilsAssembly: LookHeartAssembly {
    func assemble(container: Container) {
        // DateTime
        container.register(MyDateTime.self) { _ in
            return MyDateTime.shared
        }
        
        // ui
        container.register(CreateUI.self) { _ in
            return CreateUI.shared
        }
        
    }
}
