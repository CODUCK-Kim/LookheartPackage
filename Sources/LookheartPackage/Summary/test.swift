////
////  File.swift
////  
////
////  Created by 정연호 on 10/29/24.
////
//
//import Foundation
//
//import Foundation
//import UIKit
//import DGCharts
//

    
//    
//    private func buttonEnable() {
//        yesterdayButton.isEnabled = !yesterdayButton.isEnabled
//        tomorrowButton.isEnabled = !tomorrowButton.isEnabled
//        todayButton.isEnabled = !todayButton.isEnabled
//        twoDaysButton.isEnabled = !twoDaysButton.isEnabled
//        threeDaysButton.isEnabled = !threeDaysButton.isEnabled
//    }
//    
//    // MARK: - VDL
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        initVar()
//        
//        addViews()
//        
//        setCalendarClosure()
//
//    }
//    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesBegan(touches, with: event)
//        dissmissCalendar()
//    }
//    
//    public func refreshView(type: LineChartType) {
//        
//        chartType = type
//        currentButtonFlag = .TODAY
//        
//        startDate = MyDateTime.shared.getCurrentDateTime(.DATE)
//        endDate = MyDateTime.shared.dateCalculate(startDate, setDate(.TODAY), PLUS_DATE)
//        
////        getDataToServer(startDate: startDate, endDate: endDate, type: currentButtonFlag)
//        
//        setDisplayDateText()
//        setButtonColor(todayButton)
//    }
//    
//    
//    func initVar() {
//        buttonList = [todayButton, twoDaysButton, threeDaysButton]
//    }
//    
//    
//    // MARK: - CHART FUNC
//    func viewChart(_ bpmDataList: [LineChartDataModel], _ type: DateType) {
//        let dataDict = groupDataByDate(bpmDataList)
//        var entries: [String : [ChartDataEntry]] = [:]
//        var timeSets: Set<String> = []
//
//        // setTimeTable
//        for (date, dataForDate) in dataDict {
//
//            entries[date] = [ChartDataEntry]()
//
//            let timeSet = Set(dataForDate.map { $0.writeTime })
//            timeSets.formUnion(timeSet)
//        }
//
//        let timeTable = timeSets.sorted()    // 시간 정렬
//
//        // setDictionary
//        let dataByTimeDict = setDictionary(dataDict)
//
//        // setEntries
//        entries = setEntries(entries: entries, timeTable: timeTable, dictionary: dataByTimeDict)
//
//        // setChart
//        let chartDataSets = setChartDataSets(entries: entries, type: type)
//        setChart(chartData: LineChartData(dataSets: chartDataSets),
//                 maximum: 1000,
//                 axisMaximum: 200,    // default: 200, stress: 900, chartType == .BPM ? 200 : 900
//                 axisMinimum: chartType == .BPM ? 40 : 0,
//                 timeTable: timeTable)
//
//        activityIndicator.stopAnimating()
//    }
//    
//    
//    func setDictionary(_ dataDict: [String : [LineChartDataModel]]) -> [String: [String: [LineChartDataModel]]] {
//        // [ 날짜 : [ 시간 : [BpmData] ]
//        var dataByTimeDict: [String: [String: [LineChartDataModel]]] = [:]
//
//        for (date, dataForDate) in dataDict {
//            var timeDict: [String: [LineChartDataModel]] = [:]
//            for data in dataForDate {
//                timeDict[data.writeTime, default: []].append(data)
//            }
//            dataByTimeDict[date] = timeDict
//        }
//
//        return dataByTimeDict
//    }
//  
//    func setEntries(
//        entries: [String : [ChartDataEntry]],
//        timeTable: [String],
//        dictionary: [String: [String: [LineChartDataModel]]]
//    ) -> [String : [ChartDataEntry]] {
//        let type = chartType == .BPM
//        var resultEntries = entries
//
//        for i in 0..<timeTable.count {
//            let time = timeTable[i]
//
//            for (date, timeDict) in dictionary {
//                if let bpmDataArray = timeDict[time], !bpmDataArray.isEmpty {
//                    // 데이터 존재
//                    let value = type ? bpmDataArray[0].bpm ?? 0 : bpmDataArray[0].hrv ?? 0
//
//                    calcMinMax(value)
//
//                    let entry = ChartDataEntry(x: Double(i), y: value)
//                    resultEntries[date]?.append(entry)
//                }
//            }
//        }
//        return resultEntries
//    }
//    
//    
//    // MARK: -
//    private func groupDataByDate(_ bpmDataArray: [LineChartDataModel]) -> [String: [LineChartDataModel]] {
//        // 날짜별("YYYY-MM-DD")로 데이터 그룹화
//        let groupedData = bpmDataArray.reduce(into: [String: [LineChartDataModel]]()) { dict, bpmData in
//            let dateKey = String(bpmData.writeDate)
//            dict[dateKey, default: []].append(bpmData)
//        }
//        return groupedData
//    }
//
//
//    private func getDataToServer(
//        startDate: String,
//        endDate: String,
//        type: DateType
//    ) {
//        activityIndicator.startAnimating()
//
//        initUI()
//
//        Task {
//            let getHourlyData = await graphService.getBpmData(startDate: startDate, endDate: endDate, type: chartType)
//            let data = getHourlyData.0
//            let response = getHourlyData.1
//
//            switch response {
//            case .success:
//                DispatchQueue.main.async {
//                    self.viewChart(data!, type)
//                }
//            case .noData:
//                toastMessage("dialog_error_noData".localized())
//            default:
//                toastMessage("dialog_error_server_noData".localized())
//            }
//
//            activityIndicator.stopAnimating()
//        }
//    }
//    
//    
//    func chartDataSet(color: NSUIColor, chartDataSet: LineChartDataSet) -> LineChartDataSet {
//        chartDataSet.drawCirclesEnabled = false
//        chartDataSet.setColor(color)
//        chartDataSet.mode = .linear
//        chartDataSet.lineWidth = 0.7
//        chartDataSet.drawValuesEnabled = true
//        return chartDataSet
//    }
//
//    func setChartDataSets(entries: [String : [ChartDataEntry]], type: DateType) -> [LineChartDataSet] {
//        let graphColor = setGraphColor(type)
//        var graphIdx = 0
//
//        var chartDataSets: [LineChartDataSet] = []
//        var dateChartDict: [String : LineChartDataSet] = [:]
//        var dateText: [String] = []
//
//        for (date, entry) in entries {
//            let label = MyDateTime.shared.changeDateFormat(date, false)
//            let chartDataSet = chartDataSet(color: graphColor[graphIdx], chartDataSet: LineChartDataSet(entries: entry, label: label))
//            dateChartDict[date] = chartDataSet
//            graphIdx += 1
//        }
//
//        // 시간순으로 정렬
//        let sortedDates = dateChartDict.keys.sorted()
//        for date in sortedDates {
//            if let chartDataSet = dateChartDict[date] {
//                chartDataSets.append(chartDataSet)
//                dateText.append(date)
//            }
//        }
//
//        setUI()
//
//        return chartDataSets
//    }
//    
//    func setChart(
//        chartData: LineChartData,
//        maximum: Double,
//        axisMaximum: Double,
//        axisMinimum: Double,
//        timeTable: [String]
//    ) {
//        lineChartView.data = chartData
//        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: timeTable)
//        lineChartView.setVisibleXRangeMaximum(maximum)
//        lineChartView.leftAxis.axisMaximum = axisMaximum
//        lineChartView.leftAxis.axisMinimum = axisMinimum
//        lineChartView.data?.notifyDataChanged()
//        lineChartView.notifyDataSetChanged()
//        lineChartView.moveViewToX(0)
//        chartZoomOut()
//    }
//    
//    func setGraphColor(_ type : DateType) -> [UIColor] {
//        switch (type) {
//        case .TODAY:
//            return [NSUIColor.GRAPH_RED]
//        case .TWO_DAYS:
//            return [NSUIColor.GRAPH_RED, NSUIColor.GRAPH_BLUE]
//        case .THREE_DAYS:
//            return [NSUIColor.GRAPH_RED, NSUIColor.GRAPH_BLUE, NSUIColor.GRAPH_GREEN]
//        }
//    }
//    
//    // MARK: - DATE FUNC
//    private func setDate(_ type : DateType) -> Int {
//        switch (type) {
//        case .TODAY:
//            return 1
//        case .TWO_DAYS:
//            return 2
//        case .THREE_DAYS:
//            return 3
//        }
//    }
//    
//    
//    private func setCalendarClosure() {
//        fsCalendar.didSelectDate = { [self] date in
//                        
//            currentButtonFlag = .TODAY
//            
//            startDate = MyDateTime.shared.getDateFormat().string(from: date)
//            endDate = MyDateTime.shared.dateCalculate(startDate, setDate(.TODAY), PLUS_DATE)
//            
////            getDataToServer(startDate: startDate, endDate: endDate, type: currentButtonFlag)
//            
//            setDisplayDateText()
//            setButtonColor(todayButton)
//            
//            fsCalendar.isHidden = true
//            lineChartView.isHidden = false
//        }
//    }
//}
