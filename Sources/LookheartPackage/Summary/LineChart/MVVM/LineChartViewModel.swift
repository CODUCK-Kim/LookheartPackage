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
    @Published var chartModel: LineChartModel?
    @Published var displayDate: String?
    @Published var initValue: Void?
    @Published var loading: Bool = false
    
    // DI
    private let repository: LineChartRepository
    
    init (repository: LineChartRepository) {
        self.repository = repository
    }
    
    func updateChartData() {
        displayDate = repository.getDisplayDate()
        
        initValue = ()
        
        Task {
            loading = true
            
            let (chartModel, response) = await repository.getLineChartGropData()
            
            switch response {
            case .success:
                // update model
                if let chartModel {
                    updateChartModel(lineChartModel: chartModel)
                } else {
                    networkResponse = .noData
                }
            default:
                networkResponse = response
            }
            
            loading = false
        }
    }
    
    private func updateChartModel(lineChartModel: LineChartModel) {
        var entries: [String : [ChartDataEntry]] = [:]
        var valueArray: [Double] = []
        
        var copyModel = lineChartModel
        let size = lineChartModel.timeTable.count
        let timeTable = lineChartModel.timeTable
        let dictionary = lineChartModel.dictData
        
        // value
        var maxValue = 0.0
        var minValue = 70.0
        
        var avgSumValue = 0.0
        var avgCnt = 0
        
        var standardDeviationValue = 0.0    // 표준 편차
        
        var secondMaxValue = 0.0
        var secondMinValue = 70.0
        var secondAvgValue = 0.0
        var secondAvgCnt = 0
        
        // init entries
        lineChartModel.dictData.keys.forEach { key in
            entries[key] = [ChartDataEntry]()
        }
        
        
        // set entries
        for i in 0..<size {
            let time = timeTable[i]
            
            for (date, timeDict) in dictionary {
                if let data = timeDict[time] {
                    let value: Double?
                    
                    switch lineChartModel.chartType {
                    case .BPM:
                        value = data.bpm
                    case .HRV:
                        value = data.hrv
                    case .SPO2:
                        value = data.spo2
                    case .BREATHE:
                        value = data.breathe
                    case .STRESS:
                        if date == "pns" {
                            value = data.pns
                        } else {
                            // sns
                            value = data.sns
                        }
                    }

                    // value
                    if let value {
                        let entry = ChartDataEntry(x: Double(i), y: value)
                            
                        entries[date]?.append(entry)
                        valueArray.append(value)
                        
                        switch lineChartModel.chartType {
                        case .BPM, .HRV, .SPO2, .BREATHE:
                            maxValue = max(maxValue, value)
                            minValue = min(minValue, value)
                            avgSumValue += value
                            avgCnt += 1
                        case .STRESS:
                            if date == "pns" {
                                maxValue = max(maxValue, value)
                                minValue = min(minValue, value)
                                avgSumValue += value
                                avgCnt += 1
                            } else {
                                // sns
                                secondMaxValue = max(secondMaxValue, value)
                                secondMinValue = min(secondMinValue, value)
                                secondAvgValue += value
                                secondAvgCnt += 1
                            }
                        }
                    }
                }
            }
        }
                
        // 표준 편차
        switch lineChartModel.chartType {
        case .BPM, .HRV, .SPO2, .BREATHE:
            let avgValue = avgSumValue / Double(avgCnt)
            var sumSquareValue = 0.0
            
            valueArray.forEach { value in
                let deviation = value - avgValue
                let squaredDeviation = deviation * deviation // 편차 제곱
                
                sumSquareValue += squaredDeviation
            }
            
            let variance = sumSquareValue / Double(valueArray.count) // 분산
            
            standardDeviationValue = sqrt(variance) // 제곱근
        case .STRESS:
            break
        }
        
        
        copyModel.entries = entries
        copyModel.maxValue = maxValue
        copyModel.minValue = minValue
        copyModel.avgValue = avgSumValue / Double(avgCnt)
        copyModel.standardDeviationValue = standardDeviationValue
        
        copyModel.secondMaxValue = secondMaxValue
        copyModel.secondMinValue = secondMinValue
        copyModel.secondAvgValue = secondAvgValue / Double(secondAvgCnt)
        
        self.chartModel = copyModel
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
    
    func moveDate(moveDate: Date) {
        repository.updateTargetDate(moveDate)
        
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
