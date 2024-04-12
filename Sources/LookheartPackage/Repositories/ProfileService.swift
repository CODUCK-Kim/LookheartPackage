//
//  File.swift
//  
//
//  Created by 정연호 on 2024/04/12.
//

import Foundation

@available(iOS 13.0.0, *)
public class ProfileService {
    public static let shared = ProfileService()
    
    public init() {}
    
    public func getProfile(id: String) async -> (UserProfile?, NetworkResponse) {
        var params: [String: Any] = [
            "empid": id
        ]
        
        do {
            let profiles: [UserProfile] = try await AlamofireController.shared.alamofireControllerAsync(
                parameters: params,
                endPoint: .getProfile,
                method: .get)
            
            var phoneNumbers: [String] = []
            
            for profile in profiles { // guardian Phone Numbers
                if let phones = profile.phone {
                    phoneNumbers.append(phones)
                }
            }
            
            if let userProfile = profiles.first {
                UserProfileManager.shared.guardianPhoneNumber = phoneNumbers
                return (userProfile, .success)
            } else {
                return (nil, .noData)
            }
            
        } catch {
            return (nil, AlamofireController.shared.handleError(error))
        }
    }
    
    
    
    public func postAccountDeletion(params: [String: Any]) async -> NetworkResponse {
        do {
            let response = try await AlamofireController.shared.alamofireControllerForString(
                parameters: params,
                endPoint: .postSetProfile,
                method: .post)
            
            if response.contains("true") {
                return .success
            } else {
                return .failer
            }
        } catch {
            return AlamofireController.shared.handleError(error)
        }
    }
    
    public func postUpdateLogout() async {
        var params: [String: Any] = [
            "kind": "updateDifferTime",
            "eq": propEmail,
            "differtime": "0"
        ]
        
        do {
            let response = try await AlamofireController.shared.alamofireControllerForString(
                parameters: params,
                endPoint: .postSetProfile,
                method: .post)
            
            print("postUpdateLogout: \(response)")
        } catch {
            print("postUpdateLogout: \(error)")
        }
    }
}
