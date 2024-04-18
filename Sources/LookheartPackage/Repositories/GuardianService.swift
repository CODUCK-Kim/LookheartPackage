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
    
    public struct BpmTime: Codable {
        public var bpm: Int
        public var temp: Double
        public var writetime: String
    }
    
    public struct TotalHourlyData {
        public var step: Int = 0
        public var distance: Int = 0
        public var calorie: Int = 0
        public var activityCal: Int = 0
        public var arrCnt: Int = 0
        
        mutating func updateData(data: TotalHourlyData) {
            arrCnt += data.arrCnt
            activityCal += data.activityCal
            calorie += data.calorie
            step += data.step
            distance += data.distance
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
        ]
        
        do {
            let response = try await AlamofireController.shared.alamofireControllerForString(
                parameters: params,
                endPoint: .getCheckLogin,
                method: .get)
            
            print("loginGuardian: \(response)")
            
            if response.contains("true") {
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
            let response = try await AlamofireController.shared.alamofireControllerForString(
                parameters: params,
                endPoint: .getCheckLogin,
                method: .get)
            
            print("sendToken: \(response)")
            if response.contains("true") {
                return .success
            } else {
                return .failer
            }
        } catch {
            return AlamofireController.shared.handleError(error)
        }
    }
    
    
    public func getBpmTime(_ id: String) async -> (BpmTime?, NetworkResponse) {
        let params: [String: Any] = [
            "eq": id,
        ]
        // {"bpm":58,"writetime":"2024-02-06 12:17:05"}
        do {
            let response: BpmTime = try await AlamofireController.shared.alamofireControllerAsync(
                parameters: params,
                endPoint: .getBpmTime,
                method: .get)
            
            print("getBpmTime: \(response)")
            
            return (response, .success)
        } catch {
            return (nil, AlamofireController.shared.handleError(error))
        }
    }
    
    
    
    public func getHourlyData(
        startDate: String,
        endDate: String
    ) async -> (TotalHourlyData?, NetworkResponse) {
        let parameters: [String: Any] = [
            "eq": propEmail,
            "startDate": startDate,
            "endDate": endDate
        ]
        
        do {
            let hourlyData = try await AlamofireController.shared.alamofireControllerForString(
                parameters: parameters,
                endPoint: .getHourlyData,
                method: .get)
            
            guard !hourlyData.contains("result = 0") else {
                return (nil, .noData)
            }
            
            let newlineData = hourlyData.split(separator: "\n").dropFirst()
            guard newlineData.count > 0 else {
                return (nil, .invalidResponse)
            }
            
            let splitData = newlineData.first?.split(separator: "\r\n")
            var totalHourlyData = TotalHourlyData()
            
            if let splitData = splitData {
                for data in splitData {
                    let fields = data.split(separator: "|")
                    if fields.count == 12 {
                        guard let step = Int(fields[7]),
                              let distance = Int(fields[8]),
                              let cal = Int(fields[9]),
                              let activityCal = Int(fields[10]),
                              let arrCnt = Int(fields[11]) else {
                            continue // Skip this record if any conversions fail
                        }
                        
                        totalHourlyData.updateData(data: TotalHourlyData(
                            step: step,
                            distance: distance,
                            calorie: cal,
                            activityCal: activityCal,
                            arrCnt: arrCnt
                        ))
                    }
                }
                
                return (totalHourlyData, .success)
            } else {
                return (nil, .failer)
            }
        } catch {
            return (nil, AlamofireController.shared.handleError(error))
        }
    }
}
