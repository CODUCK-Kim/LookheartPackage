//
//  File.swift
//  
//
//  Created by KHJ on 2024/04/12.
//

import Foundation

@available(iOS 13.0.0, *)
public class LoginService {
    public static let shared = LoginService()
    
    public init() {}
    
    public func loginTask(
        _ email: String,
        _ password: String, 
        _ destroy:Bool = false
    ) async -> NetworkResponse {
        let parameters: [String: Any] = [
            "empid": email,
            "pw": password,
            "destroy": destroy
        ]
        
        do {
            let checkLogin = try await AlamofireController.shared.alamofireControllerForString(
                parameters: parameters,
                endPoint: .getCheckLogin,
                method: .get)
            
            if checkLogin.contains("true") || checkLogin.contains("다른"){
                return .success
            } else {
                return .failer
            }
        } catch {
            return AlamofireController.shared.handleError(error)
        }
    }
    
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
    
    public func getAppKey(_ appKey: String, _ email: String) async -> NetworkResponse {
        let parameters: [String: Any] = [
            "empid": email
        ]
        
        do {
            let getAppKey =  try await AlamofireController.shared.alamofireControllerForString(
                parameters: parameters,
                endPoint: .getAppKey,
                method: .get)
            
            print(getAppKey)
            if getAppKey.contains(appKey) {
                return .success
            } else {
                return .failer
            }
        } catch {
            return AlamofireController.shared.handleError(error)
        }
    }

    
    public func postAppKey(_ appKey: String, _ email: String) async -> NetworkResponse {
        let parameters: [String: Any] = [
            "kind": "updateAppKey",
            "eq": email,
            "appKey": appKey
        ]
        
        do {
            let postAppKey =  try await AlamofireController.shared.alamofireControllerForString(
                parameters: parameters,
                endPoint: .postSetProfile,
                method: .post)
            
            print(postAppKey)
            if postAppKey.contains("true") {
                return .success
            } else {
                return .failer
            }
        } catch {
            return AlamofireController.shared.handleError(error)
        }
    }
}
