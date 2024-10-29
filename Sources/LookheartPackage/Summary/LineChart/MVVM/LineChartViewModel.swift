//
//  File.swift
//  
//
//  Created by 정연호 on 10/29/24.
//

import Foundation
import Combine
import DGCharts

class LineChartViewModel {
    // Combine
    @Published var networkResponse: NetworkResponse?
    @Published var entries: [String : [ChartDataEntry]]?
    
    // DI
    private let repository: LineChartRepository
    
    init (repository: LineChartRepository) {
        self.repository = repository
    }
    
    func updateChartData() {
        Task {
            let (groupData, response) = await repository.getLineChartGropData()

            switch response {
            case .success: 
                updateEntries(lineChartGroupedData: groupData!)
            default:
                networkResponse = response
            }
        }
    }
    
    private func updateEntries(lineChartGroupedData: LineChartGroupedData) {
        var entries: [String : [ChartDataEntry]] = [:]
        
        let size = lineChartGroupedData.timeTable.count
        let timeTable = lineChartGroupedData.timeTable
        let dictionary = lineChartGroupedData.dictData
        
        // init entries
        lineChartGroupedData.dictData.keys.forEach { key in
            entries[key] = [ChartDataEntry]()
        }
        
        // set entries
        for i in 0..<size {
            let time = timeTable[i]
            
            for (date, timeDict) in dictionary {
                if let data = timeDict[time] {
                    let value: Double?
                    
                    switch lineChartGroupedData.type {
                    case .BPM:
                        value = data.bpm
                    case .HRV:
                        value = data.hrv
                    case .STRESS:
                        if date == "pns" {
                            value = data.pns
                        } else {
                            value = data.sns
                        }
                    }
                    
                    if let value {
                        let entry = ChartDataEntry(x: Double(i), y: value)
                        entries[date]?.append(entry)
                    }
                }
            }
        }
        
        self.entries = entries
    }
    
    
    
    // Update Data
    func refresh(type: LineChartType) {
        repository.refreshData(type)
        
        updateChartData()
    }
    
    func moveDate(nextDate: Bool) {
        repository.updateTargetDate(nextDate)
        
        updateChartData()
    }
    
    func updateChartType(_ updateType: LineChartType) {
        repository.updateChartType(type: updateType)
        
        updateChartData()
    }
    
    func updateDateType(_ updateType: LineChartDateType) {
        repository.updateChartDateType(type: updateType)
        
        updateChartData()
    }
}
