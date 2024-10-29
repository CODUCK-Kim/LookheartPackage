//
//  File.swift
//  
//
//  Created by 정연호 on 10/29/24.
//

import Foundation
import Swinject

public protocol Assembly {
    func assemble(container: Container)
}
