//
//  File.swift
//  
//
//  Created by 정연호 on 8/1/24.
//

import Foundation

public class GoogleService {
    
    public init() {}
    
    public func oAuth() async -> String? {
    
        let parameters: [String: Any] = [:]
        
        do {
            let auth = try await AlamofireController.shared.alamofireControllerForString(
                parameters: parameters,
                endPoint: .googleAuth,
                method: .get)
            
            return auth
            
        } catch {
            print(error)
        }
        
        return nil
    }
}
