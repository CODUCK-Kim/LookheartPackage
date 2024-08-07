//
//  File.swift
//  
//
//  Created by KHJ on 2024/04/12.
//

import Foundation
import Alamofire

public class NetworkService: NetworkProtocol {
    public init() {}
    
    func task<T: Decodable>(
        parameters: [String : Any],
        endPoit: EndPoint,
        method: HTTPMethod,
        type: T.Type
    ) async -> (result: Any?, response: NetworkResponse) {
        do {
            let result: T = try await AlamofireController.shared.alamofireControllerTask(
                parameters: parameters,
                endPoint: endPoit,
                method: method
            )
            return (result: result, response: .success)
        } catch {
            let error = AlamofireController.shared.handleError(error)
            return (result: nil, response: error)
        }
    }
}
