//
//  File.swift
//  
//
//  Created by 정연호 on 8/1/24.
//

import Foundation

public class GoogleService {
    
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
    
    public func sendGoogleLoginHtmlGetURL(html loginHtml: String) async -> String? {
        
        let parameters: [String: Any] = ["html" : loginHtml]
        
        do {
            let htmlURL = try await AlamofireController.shared.alamofireControllerForString(
                parameters: parameters,
                endPoint: .googleHtml,
                method: .get
            )
            
            return htmlURL
        } catch {
            print(error)
        }
        
        return nil
    }

}
