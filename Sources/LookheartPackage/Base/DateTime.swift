//
//  File.swift
//  
//
//  Created by 정연호 on 2024/01/09.
//

import Foundation

class MyDateTime {
    
    enum DateType {
        case DATE
        case TIME
        case DATETIME
    }
    
    static let shared = MyDateTime()
    
    private let dateFormatter = DateFormatter()
    
    public func getCurrentDateTime(_ dateType : DateType ) -> String {
        
        let now = Date()
        
        dateFormatter.dateFormat = getFormatter(dateType)
        
        return dateFormatter.string(from: now)
    }
    
    public func getSplitDateTime(_ dateType : DateType ) -> [String] {
        let now = Date()
        
        dateFormatter.dateFormat = getFormatter(dateType)
        
        var dateTime = dateFormatter.string(from: now)
        
        switch (dateType) {
        case .DATE:
            return dateTime.split(separator: "-").map { String($0) }
        case .TIME:
            return dateTime.split(separator: ":").map { String($0) }
        case .DATETIME:
            return dateTime.split(separator: " ").map { String($0) }
        }
        
    }
    
    private func getFormatter(_ dateType : DateType) -> String {
        switch (dateType) {
        case .DATE:
            return "yyyy-MM-dd"
        case .TIME:
            return "HH:mm:ss"
        case .DATETIME:
            return "yyyy-MM-dd HH:mm:ss"
        }
    }
}
