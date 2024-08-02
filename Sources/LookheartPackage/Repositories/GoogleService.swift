//
//  File.swift
//  
//
//  Created by 정연호 on 8/1/24.
//

import Foundation

public class GoogleService {
    public struct GoogleLoginURL: Decodable {
        public let url: String
    }
    
    public init() {}
    
    public func getGoogleLoginHtml() async -> String? {
    
        let parameters: [String: Any] = [:]
        
        do {
            let getGoogleLoginHtml = try await AlamofireController.shared.alamofireControllerForString(
                parameters: parameters,
                endPoint: .googleAuth,
                method: .get)
            
            return getGoogleLoginHtml
        
        } catch {
            print(error)
        }
        
        return nil
    }
    
    public func sendGoogleLoginHtmlGetURL(html loginHtml: String) async -> GoogleLoginURL? {
        
        let parameters: [String: Any] = ["html" : loginHtml]
        
        do {
            let htmlURL: GoogleLoginURL = try await AlamofireController.shared.alamofireControllerAsync(
                parameters: parameters,
                endPoint: .googleHtml,
                method: .post
            )
            
            return htmlURL
        } catch {
            print(error)
        }
        
        return nil
    }

}
