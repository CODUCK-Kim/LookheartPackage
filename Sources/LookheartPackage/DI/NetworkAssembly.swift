//
//  File.swift
//  
//
//  Created by 정연호 on 10/29/24.
//

import Foundation
import Swinject

class NetworkAssembly: Assembly {
    func assemble(container: Container) {
        // AlamofireController
        container.register(NetworkProtocol.self) { _ in
            return AlamofireController.shared
        }
        
        // UserProfile
        container.register(UserProfileManager.self) { _ in
            return UserProfileManager.shared
        }
    }
}
