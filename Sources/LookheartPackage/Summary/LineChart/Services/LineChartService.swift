//
//  File.swift
//  
//
//  Created by KHJ on 10/29/24.
//

import Foundation

class LineChartService {
    private let networkController: NetworkProtocol
    private let profile: UserProfileManager
    
    init (
        networkController: NetworkProtocol,
        profile: UserProfileManager
    ) {
        self.networkController = networkController
        self.profile = profile
    }
    
    func fetchData(
        startDate: String,
        endDate: String,
        type: LineChartType
    ) async -> (result: String?, response: NetworkResponse) {
        let endPoint = getEndPoint(type)
        
        let parameters: [String: Any] = [
//            "eq": profile.email,
            "eq": "jhaseung@medsyslab.co.kr",
//            "eq": "001948.bc98ad2f3d44485c92a65c1f72fa1db6.0117",
            
            "startDate": startDate,
            "endDate": endDate,
            
            // test
            "test": true
        ]
        
        
        let data: (result: String? ,response: NetworkResponse) = await networkController.task(
            parameters: parameters,
            endPoit: endPoint,
            method: .get,
            type: String.self
        )
        
//        print("GET_LINE_CHART_DATA: \(data)")
        
        return data
    }
    
    private func getEndPoint(_ type: LineChartType) -> EndPoint {
        return switch type {
        case .BPM, .HRV, .SPO2, .BREATHE:
            EndPoint.getBpmData
        case .STRESS:
            EndPoint.getStressData
        }
    }
}
