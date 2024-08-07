//
//  File.swift
//  
//
//  Created by KHJ on 8/7/24.
//

import Foundation
import Alamofire

protocol NetworkProtocol {
    func task<T: Decodable>(
        parameters: [String: Any],
        endPoit: EndPoint,
        method: HTTPMethod,
        type: T.Type
    ) async -> (result: Any?, response: NetworkResponse)
}
