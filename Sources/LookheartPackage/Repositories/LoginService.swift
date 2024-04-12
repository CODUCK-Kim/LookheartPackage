//
//  File.swift
//  
//
//  Created by KHJ on 2024/04/12.
//

import Foundation

@available(iOS 13.0.0, *)
public class LoginService {
    func loginTask(_ email: String, _ password: String) async -> NetworkResponse {
        let parameters: [String: Any] = [
            "empid": email,
            "pw": password,
            "destroy": "false"
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
    
    
    func getAppKey(_ appKey: String, _ email: String) async -> NetworkResponse {
        let parameters: [String: Any] = [
            "empid": email
        ]
        
        do {
            let getAppKey =  try await AlamofireController.shared.alamofireControllerForString(
                parameters: parameters,
                endPoint: .getAppKey,
                method: .get)
            
            if getAppKey.contains(appKey) {
                return .success
            } else {
                return .failer
            }
        } catch {
            return AlamofireController.shared.handleError(error)
        }
    }

    
    func postAppKey(_ appKey: String, _ email: String) async -> NetworkResponse {
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
