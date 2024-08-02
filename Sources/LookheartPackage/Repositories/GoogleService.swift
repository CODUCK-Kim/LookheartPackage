//
//  File.swift
//  
//
//  Created by 정연호 on 8/1/24.
//

import Foundation

public class GoogleService {
    public struct GoogleUser: Codable {
        let email: String
        let firstName: String
        let lastName: String
        let socialProvider: String
        let externalId: String
        let accessToken: String
    }
    
    public init() {}
    
    public func getGoogleLoginData(_ stringData: String?) -> GoogleUser? {
        if let data = stringData?.data(using:  .utf8) {
            do {
                let user = try JSONDecoder().decode(GoogleUser.self, from: data)
                return user
            } catch {
                print("GoogleLoginData JSON 디코딩 오류: \(error.localizedDescription)")
            }
        }
        
        return nil
    }
}
