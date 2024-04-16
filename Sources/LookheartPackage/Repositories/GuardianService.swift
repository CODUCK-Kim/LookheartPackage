//
//  File.swift
//  
//
//  Created by KHJ on 2024/04/16.
//

import Foundation

@available(iOS 13.0.0, *)
public class GuardianService {
    public static let shared = GuardianService()
    
    public init() {}
    
    public func loginGuardian(
        _ id: String,
        _ password: String,
        _ phone: String
    ) async -> NetworkResponse {
        let params: [String: Any] = [
            "empid": id,
            "pw": password,
            "phone": phone,
            "destroy": true
        ]
        
        do {
            let checkLogin = try await AlamofireController.shared.alamofireControllerForString(
                parameters: params,
                endPoint: .getCheckLogin,
                method: .get)
            
            if checkLogin.contains("true") {
                return .success
            } else {
                return .failer
            }
        } catch {
            return AlamofireController.shared.handleError(error)
        }
    }

    public func sendToken(
        _ id: String,
        _ password: String,
        _ phone: String,
        _ token: String
    ) async -> NetworkResponse {
        let params: [String: Any] = [
            "empid": id,
            "pw": password,
            "phone": phone,
            "token": token
        ]
        
        do {
            let checkLogin = try await AlamofireController.shared.alamofireControllerForString(
                parameters: params,
                endPoint: .getCheckLogin,
                method: .get)
            
            if checkLogin.contains("true") {
                return .success
            } else {
                return .failer
            }
        } catch {
            return AlamofireController.shared.handleError(error)
        }
    }
}
