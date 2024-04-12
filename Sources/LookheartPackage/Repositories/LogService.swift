//
//  File.swift
//  
//
//  Created by 정연호 on 2024/04/12.
//

import Foundation

@available(iOS 13.0.0, *)
public class LogService {
    public static let shared = LogService()
    
    public init() {}
    
    public enum LogType: String {
        case Login
        case AutoLogin
        case Logout
        case Shutdown
        case AccountDeletion
        
        case BleConnect
        case BleDisconnect
    }
    
    public enum UserType: String {
        case User
        case Guardian
    }
    
    public enum LoginType: String {
        case successLogin
        case failureLogin
        case duplicateLogin
    }
    
    public func sendLog(
        userType: UserType,
        action: LogType,
        phone: String? = nil
    ) async {
        var params: [String: Any] = [
            "eq": propEmail,
            "writetime": propCurrentDateTime,
            "gubun": userType.rawValue,
            "activity": action.rawValue
        ]
        
        do {
            let sendLog = try await AlamofireController.shared.alamofireControllerForString(
                parameters: params,
                endPoint: .postLog,
                method: .post)
            
            print("sendLog: \(sendLog)")
        } catch {
            print("sendLog Error: \(error)")
        }
    }
    
    public func sendBleLog(action: LogType) async {
        var params: [String: Any] = [
            "eq": propEmail,
            "phone": propProfil.phone,
            "writetime": propCurrentDateTime,
            "timezone": MyDateTime.shared.getTimeZone(),
            "activity": action.rawValue,
            "serial" : propProfil.bleIdentifier
        ]
        
        do {
            let sendBleLog = try await AlamofireController.shared.alamofireControllerForString(
                parameters: params,
                endPoint: .postBleLog,
                method: .post)
            
            print("sendLog: \(sendBleLog)")
        } catch {
            print("sendLog Error: \(error)")
        }
    }
}
