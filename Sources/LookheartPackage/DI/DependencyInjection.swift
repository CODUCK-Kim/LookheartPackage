//
//  File.swift
//  
//
//  Created by KHJ on 10/29/24.
//

import Foundation
import Swinject

class DependencyInjection {
    static let shared = DependencyInjection()
    let container: Container
    
    private init() {
        container = Container()
        
        let assemblies: [Assembly] = [
            UtilsAssembly(),
            NetworkAssembly(),
            LineChartAssembly()
        ]
        
        assemblies.forEach { $0.assemble(container: container) }
    }
    
    func registerAssemblies(_ assemblies: [Assembly]) {
        assemblies.forEach { $0.assemble(container: container) }
    }
    
    func resolve<T>(_ type: T.Type) -> T? {
        return container.resolve(type)
    }
}
