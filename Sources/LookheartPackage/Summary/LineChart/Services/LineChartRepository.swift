//
//  File.swift
//  
//
//  Created by KHJ on 10/29/24.
//

import Foundation


class LineChartRepository {
    // DI
    private let service: LineChartService
    private let dateTime: MyDateTime
    
    //
    private var targetDate: String
    private var lineChartType: LineChartType
    private var lineChartDateType: LineChartDateType
    private let decoder = JSONDecoder()
    
    init (
        service: LineChartService,
        dateTime: MyDateTime
    ) {
        self.service = service
        self.dateTime = dateTime
        
        targetDate = dateTime.getCurrentDateTime(.DATE)
        lineChartType = .BPM
        lineChartDateType = .TODAY
    }
    
    
    
    
    
    
    // MARK: -
    func getLineChartGropData() async -> (
        data: LineChartModel?,
        networkResponse: NetworkResponse
    ) {
        let startDate = getStartDate()
        let endDate = getEndDate()
        
        let data = await service.fetchData(
            startDate: startDate,
            endDate: endDate,
            type: lineChartType
        )
        
        switch data.response {
        case .success:
            // string -> parsing
            let parsingData = getParsingData(data.result)
            
            // parsing -> group
            guard let parsingResult = parsingData.result else {
                return (nil, parsingData.response)
            }
            
            let groupData = groupDataByDate(parsingResult)
            
            let lineChartGroupedData = getLineChartGroupedData(groupData)
            
            return (lineChartGroupedData, data.response)
        default:
            return (nil, data.response)
        }
    }
    
    
    
    
    
    // MARK: -
    private func getParsingData(_ data: String?) -> (
        result: [LineChartDataModel]?,
        response: NetworkResponse
    ) {
        switch (lineChartType) {
        case .BPM, .HRV:
            return parsingBpmHrvData(data)
        case .STRESS:
            return parsingStressData(data)
        }
    }
    
    
    
    
    
    // MARK: -
    // bpm & hrv
    private func parsingBpmHrvData(_ data: String?) -> (result: [LineChartDataModel]?, response: NetworkResponse) {
        guard let resultData = data else {
            return (nil, .noData)
        }
        
        guard !resultData.contains("result = 0") else {
            return (nil, .noData)
        }
        
        let newlineData = resultData.split(separator: "\n").dropFirst()
        
        guard newlineData.count > 0 else {
            return (nil, .invalidResponse)
        }
        
        guard let splitData = newlineData.first?.split(separator: "\r\n") else {
            return (nil, .invalidResponse)
        }
        
        let changedFormatData = LineChartDataModel.changeFormat(datalist: splitData)
        
        return (changedFormatData, .success)
    }
    
    
    // stress
    private func parsingStressData(_ data: String?) -> (result: [LineChartDataModel]?, response: NetworkResponse) {
        guard let resultData = data else {
            return (nil, .noData)
        }
        
        if resultData.count < 3 {
            return (nil, .noData)
        }

        guard let jsonData = resultData.data(using: .utf8) else {
            print("Error: Parsing Stress Data")
            return (nil, .invalidResponse)
        }
        
        do {
            let stressDataArray = try decoder.decode([StressDataModel].self, from: jsonData)
            
            let changedFormatData = LineChartDataModel.changeFormat(stressData: stressDataArray)
            
            return (changedFormatData, .success)
        } catch {
            print("Error decoding JSON: \(error)")
            
            return (nil, .invalidResponse)
        }
    }
    
    
    // group data
    private func groupDataByDate(
        _ parsingData : [LineChartDataModel]
    ) -> [String: [LineChartDataModel]] {
        let groupedData = parsingData.reduce(into: [String: [LineChartDataModel]]()) { dict, data in
            
            switch lineChartType {
            case .BPM, .HRV:
                // 날짜별("YYYY-MM-DD") 데이터 그룹화
                let dateKey = String(data.writeDate)
                dict[dateKey, default: []].append(data)
                
            case .STRESS:
                // 항목별(pns, sns) 데이터 그룹화
                dict["sns", default: []].append(data)
                dict["pns", default: []].append(data)
            }
        }
        
        return groupedData
    }
    
    
    // dictionary Data, time table
    func getLineChartGroupedData(_ groupData: [String : [LineChartDataModel]]) -> LineChartModel {
        var dictData: [String : [String : LineChartDataModel]] = [:]
        
        for (date, dataForDate) in groupData {
            var timeDictionary: [String: LineChartDataModel] = [:]
            
            for data in dataForDate {
                timeDictionary[data.writeTime] = data
            }
            
            dictData[date] = timeDictionary
        }
        
        // time Table
        let timeTable = Set(groupData.values.flatMap { $0.map { $0.writeTime } }).sorted()
        
        return LineChartModel(
            dictData: dictData,
            timeTable: timeTable,
            chartType: lineChartType,
            dateType: lineChartDateType
        )
    }
    
    
    
    
    // MARK: -
    func updateTargetDate(_ nextDate: Bool) {
        targetDate = dateTime.dateCalculate(targetDate, 1, nextDate)
    }
    
    func getDisplayDate() -> String {
        let startDate = getStartDate()
        
        switch (lineChartDateType) {
        case .TODAY:
            return startDate
        case .TWO_DAYS, .THREE_DAYS:
            let endDate = dateTime.dateCalculate(getEndDate(), 1, false)
            
            let startString = dateTime.changeDateFormat(startDate, false)
            let endString = dateTime.changeDateFormat(endDate, false)
            
            return "\(startString) ~ \(endString)"
        }
    }
    
    private func getStartDate() -> String {
        let day: Int
        
        switch lineChartDateType {
        case .TODAY:
            day = 0
        case .TWO_DAYS:
            day = 1
        case .THREE_DAYS:
            day = 2
        }
        
        return dateTime.dateCalculate(targetDate, day, false)
    }
    
    private func getEndDate() -> String {
        return dateTime.dateCalculate(targetDate, 1, true)
    }
    
    // MARK: -
    func refreshData(_ type: LineChartType) {
        lineChartType = type
        lineChartDateType = .TODAY
        targetDate = dateTime.getCurrentDateTime(.DATE)
    }
    
    func updateChartType(type: LineChartType) {
        lineChartType = type
    }
    
    func updateChartDateType(type: LineChartDateType) {
        lineChartDateType = type
    }
}
