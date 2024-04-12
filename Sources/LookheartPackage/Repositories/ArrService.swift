//
//  File.swift
//  
//
//  Created by 정연호 on 2024/04/12.
//

import Foundation

@available(iOS 13.0.0, *)
class ArrService {
    func getArrList(
        startDate: String,
        endDate: String
    ) async -> ([ArrDateEntry]?, NetworkResponse) {
        let parameters: [String: Any] = [
            "eq": propEmail,
            "startDate": startDate,
            "endDate": endDate
        ]
        
        do {
            let arrData: [ArrDateEntry] = try await AlamofireController.shared.alamofireControllerAsync(
                parameters: parameters,
                endPoint: .getArrListData,
                method: .get)
            
            return (arrData, .success)
            
        } catch {
            return (nil, AlamofireController.shared.handleError(error))
        }
    }
}
