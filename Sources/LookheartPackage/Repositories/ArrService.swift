//
//  File.swift
//  
//
//  Created by 정연호 on 2024/04/12.
//

import Foundation

@available(iOS 13.0.0, *)
public class ArrService {
    public init() {}
    
    public func getArrList(
        startDate: String,
        endDate: String
    ) async -> ([ArrDateEntry]?, NetworkResponse) {
        let parameters: [String: Any] = [
            "eq": propEmail,
            "startDate": startDate,
            "endDate": endDate
        ]
        
        do {
            let arrList: [ArrDateEntry] = try await AlamofireController.shared.alamofireControllerAsync(
                parameters: parameters,
                endPoint: .getArrListData,
                method: .get)
            
            return (arrList, .success)
        } catch {
            return (nil, AlamofireController.shared.handleError(error))
        }
    }
    
    public func getArrData(startDate: String) async -> (ArrData?, NetworkResponse) {
        let parameters: [String: Any] = [
            "eq": propEmail,
            "startDate": startDate,
            "endDate": ""
        ]
        
        do {
            let arrData: [ArrEcgData] = try await AlamofireController.shared.alamofireControllerAsync(
                parameters: parameters,
                endPoint: .getArrListData,
                method: .get)
            
            let resultString = arrData[0].ecgpacket.split(separator: ",")
            
            let emergencyFlag = resultString.count == 500
            
            // Arr(504), Emergency(500)
            if resultString.count > 500 {
                let startIdx = emergencyFlag ? 0 : 4
                let ecgData = resultString[startIdx...].compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
                
                let arrData = ArrData.init(
                    idx: "0",
                    writeTime: "0",
                    time: emergencyFlag ? "" : self.removeWsAndNl(resultString[0]),
                    timezone: "0",
                    bodyStatus: emergencyFlag ? "" : self.removeWsAndNl(resultString[2]),
                    type: emergencyFlag ? "" : self.removeWsAndNl(resultString[3]),
                    data: ecgData)

                return (arrData, .success)
            } else {
                return (nil, .success)
            }
        } catch {
            return (nil, AlamofireController.shared.handleError(error))
        }
    }
    
    private func removeWsAndNl(_ string: Substring) -> String {
        return string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    
    public func getEmergencyData(startDate: String) async {
        let parameters: [String: Any] = [
            "eq": propEmail,
            "startDate": startDate,
            "endDate": ""
        ]
        print("startDate: \(startDate)")
        do {
            let emergencyData = try await AlamofireController.shared.alamofireControllerForString(
                parameters: parameters,
                endPoint: .getArrListData,
                method: .get)
            
            print("emergencyData: \(emergencyData)")

        } catch {
            
        }
    }
}
