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
//@available(iOS 13.0, *)
//class LineChartVC : UIViewController {
//
//    // ViewModel
//    private let viewModel = DependencyInjection.shared.resolve(LineChartViewModel.self)
//    
//    // ----------------------------- Image ------------------- //
//    private let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .light)
//    private lazy var calendarImage =  UIImage( systemName: "calendar", withConfiguration: symbolConfiguration)?.withTintColor(.darkGray, renderingMode: .alwaysOriginal)
//    // Image End
//    
//
//    private var chartType: LineChartType = .BPM
//    
//    enum DateType {
//        case TODAY
//        case TWO_DAYS
//        case THREE_DAYS
//    }
//
//    
//    // ----------------------------- TAG ------------------- //
//    // 버튼 상수
//    private let YESTERDAY_BUTTON_FLAG = 1
//    private let TOMORROW_BUTTON_FLAG = 2
//    
//    private let TODAY_FLAG = 1
//    private let TWO_DAYS_FLAG = 2
//    private let THREE_DAYS_FLAG = 3
//    
//    private let PLUS_DATE = true, MINUS_DATE = false
//    // TAG END
//    
//    // ----------------------------- UI ------------------- //
//    // 보여지는 변수
//    private var min = 70, max = 0, avg = 0, avgSum = 0, avgCnt = 0
//    // UI VAR END
//    
//    // ----------------------------- DATE ------------------- //
//    private var startDate = String()
//    private var endDate = String()
//    // DATE END
//    
//    // ----------------------------- CHART ------------------- //
//    // 차트 관련 변수
//    private var currentButtonFlag: DateType = .TODAY   // 현재 버튼 플래그가 저장되는 변수
//    private var buttonList:[UIButton] = []
//    // CHART END
//
//    
//    private let graphService = GraphService()
//    
//    
//    // MARK: - UI VAR
//    private let safeAreaView = UIView()
//    
//    //    ----------------------------- Loding Bar -------------------    //
//    private lazy var activityIndicator = UIActivityIndicatorView().then {
//        // indicator 스타일 설정
//        $0.style = UIActivityIndicatorView.Style.large
//    }
//    
//    //    ----------------------------- FSCalendar -------------------    //
//    private lazy var fsCalendar = CustomCalendar(frame: CGRect(x: 0, y: 0, width: 300, height: 300)).then {
//        $0.isHidden = true
//    }
//    
//    private lazy var lineChartView = LineChartView().then {
//        $0.noDataText = ""
//        $0.xAxis.enabled = true
//        $0.legend.font = .systemFont(ofSize: 15, weight: .bold)
//        $0.xAxis.granularity = 1
//        $0.xAxis.labelPosition = .bottom
//        $0.xAxis.drawGridLinesEnabled = false
//        $0.rightAxis.enabled = false
//        $0.drawMarkers = false
//        $0.dragEnabled = true
//        $0.pinchZoomEnabled = false
//        $0.doubleTapToZoomEnabled = false
//        $0.highlightPerTapEnabled = false
//    }
//    
//    //    ----------------------------- UILabel -------------------    //
//    private let bottomLabel = UILabel().then {  $0.isUserInteractionEnabled = true  }
//    
//    private let topContents = UILabel().then {  $0.isUserInteractionEnabled = true  }
//    
//    private let middleContents = UILabel().then {   $0.isUserInteractionEnabled = true  }
//    
//    private let bottomContents = UILabel().then {   $0.isUserInteractionEnabled = true  }
//    
//
//    // MARK: - Top
//    private lazy var todayButton = UIButton().then {
//        $0.setTitle ("unit_today".localized(), for: .normal )
//        
//        $0.setTitleColor(.lightGray, for: .normal)
//        $0.setTitleColor(.white, for: .selected)
//        $0.setTitleColor(.lightGray, for: .disabled)
//        
//        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
//        $0.setBackgroundColor(UIColor.MY_LIGHT_GRAY_BORDER, for: .normal)
//        $0.setBackgroundColor(UIColor.MY_LIGHT_GRAY_BORDER, for: .disabled)
//        $0.setBackgroundColor(UIColor.MY_BODY_STATE, for: .selected)
//        
//        $0.layer.masksToBounds = true
//        $0.layer.cornerRadius = 15
//        $0.isSelected = true
//        
//        $0.tag = TODAY_FLAG
//        $0.addTarget(self, action: #selector(selectDayButton(_:)), for: .touchUpInside)
//    }
//    
//    private lazy var twoDaysButton = UIButton().then {
//        $0.setTitle ("unit_twoDays".localized(), for: .normal )
//        
//        $0.setTitleColor(.lightGray, for: .normal)
//        $0.setTitleColor(.white, for: .selected)
//        $0.setTitleColor(.lightGray, for: .disabled)
//        
//        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
//        $0.setBackgroundColor(UIColor.MY_LIGHT_GRAY_BORDER, for: .normal)
//        $0.setBackgroundColor(UIColor.MY_LIGHT_GRAY_BORDER, for: .disabled)
//        $0.setBackgroundColor(UIColor.MY_BODY_STATE, for: .selected)
//        
//        $0.layer.masksToBounds = true
//        $0.layer.cornerRadius = 15
//        
//        $0.tag = TWO_DAYS_FLAG
//        $0.addTarget(self, action: #selector(selectDayButton(_:)), for: .touchUpInside)
//    }
//    
//    private lazy var threeDaysButton = UIButton().then {
//        $0.setTitle ("unit_threeDays".localized(), for: .normal )
//        
//        $0.setTitleColor(.lightGray, for: .normal)
//        $0.setTitleColor(.white, for: .selected)
//        $0.setTitleColor(.lightGray, for: .disabled)
//        
//        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
//        $0.setBackgroundColor(UIColor.MY_LIGHT_GRAY_BORDER, for: .normal)
//        $0.setBackgroundColor(UIColor.MY_LIGHT_GRAY_BORDER, for: .disabled)
//        $0.setBackgroundColor(UIColor.MY_BODY_STATE, for: .selected)
//        
//        $0.layer.masksToBounds = true
//        $0.layer.cornerRadius = 15
//        
//        $0.tag = THREE_DAYS_FLAG
//        $0.addTarget(self, action: #selector(selectDayButton(_:)), for: .touchUpInside)
//    }
//    
//    
//    // MARK: - Middle
//    private lazy var todayDisplay = UILabel().then {
//        $0.text = "-"
//        $0.textColor = .black
//        $0.textAlignment = .center
//        $0.baselineAdjustment = .alignCenters
//        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
//    }
//    
//    private lazy var yesterdayButton = UIButton().then {
//        $0.setImage(leftArrow, for: UIControl.State.normal)
//        $0.tag = YESTERDAY_BUTTON_FLAG
//        $0.addTarget(self, action: #selector(shiftDate(_:)), for: .touchUpInside)
//    }
//    
//    private lazy var tomorrowButton = UIButton().then {
//        $0.setImage(rightArrow, for: UIControl.State.normal)
//        $0.tag = TOMORROW_BUTTON_FLAG
//        $0.addTarget(self, action: #selector(shiftDate(_:)), for: .touchUpInside)
//    }
//    
//    private lazy var calendarButton = UIButton(type: .custom).then {
//        $0.setImage(calendarImage, for: .normal)
//        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 100)
//        $0.addTarget(self, action: #selector(calendarButtonEvent(_:)), for: .touchUpInside)
//    }
//    
//    
//    // MARK: - Bottom
//    private let leftContents = UILabel()
//    
//    private let rightContents = UILabel()
//    
//    private let centerContents = UILabel()
//    
//    private let maxLabel = UILabel().then {
//        $0.text = "unit_max".localized()
//        $0.textColor = .lightGray
//        $0.font = UIFont.systemFont(ofSize: 18, weight: .medium)
//    }
//    
//    private let maxValue = UILabel().then {
//        $0.text = "0"
//        $0.textColor = .lightGray
//        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
//    }
//    
//    private let diffMax = UILabel().then {
//        $0.text = "0"
//        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
//        $0.textColor = UIColor(red: 239/255, green: 80/255, blue: 123/255, alpha: 1.0)
//    }
//    
//    private let minLabel = UILabel().then {
//        $0.text = "unit_min".localized()
//        $0.font = UIFont.systemFont(ofSize: 18, weight: .medium)
//        $0.textColor = .lightGray
//    }
//    
//    private let minValue = UILabel().then {
//        $0.text = "0"
//        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
//        $0.textColor = .lightGray
//    }
//    
//    private let diffMin = UILabel().then {
//        $0.text = "0"
//        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
//        $0.textColor = UIColor(red: 83/255, green: 136/255, blue: 247/255, alpha: 1.0)
//    }
//    
//    private let avgLabel = UILabel().then {
//        $0.text = "unit_bpm_avg".localized()
//        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
//    }
//    
//    private let avgValue = UILabel().then {
//        $0.text = "0"
//        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
//    }
//    
//    private let valueLabel = UILabel().then {
//        $0.text = "unit_bpm_upper".localized()
//        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
//    }
//    
//    // MARK: - Button Evnet
//    @objc func selectDayButton(_ sender: UIButton) {
//        switch(sender.tag) {
//        case TWO_DAYS_FLAG:
//            currentButtonFlag = .TWO_DAYS
//        case THREE_DAYS_FLAG:
//            currentButtonFlag = .THREE_DAYS
//        default:
//            currentButtonFlag = .TODAY
//        }
//        
//        startDate = MyDateTime.shared.dateCalculate(endDate, setDate(currentButtonFlag), MINUS_DATE)
//        
////        getDataToServer(startDate: startDate, endDate: endDate, type: currentButtonFlag)
//        setButtonColor(sender)
//        setDisplayDateText()
//    }
//    
//    @objc func shiftDate(_ sender: UIButton) {
//        
//        switch(sender.tag) {
//        case YESTERDAY_BUTTON_FLAG:
//            startDate = MyDateTime.shared.dateCalculate(startDate, 1, MINUS_DATE)
//        default:    // TOMORROW_BUTTON_FLAG
//            startDate = MyDateTime.shared.dateCalculate(startDate, 1, PLUS_DATE)
//        }
//        
//        endDate = MyDateTime.shared.dateCalculate(startDate, setDate(currentButtonFlag), PLUS_DATE)
//        
////        getDataToServer(startDate: startDate, endDate: endDate, type: currentButtonFlag)
//        setDisplayDateText()
//    }
//    
//    @objc func calendarButtonEvent(_ sender: UIButton) {
//        fsCalendar.isHidden = !fsCalendar.isHidden
//        lineChartView.isHidden = !lineChartView.isHidden
//    }
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
//    
//    // MARK: - UI
//    private func setDisplayDateText() {
//        var displayText = startDate
//        let startDateText = MyDateTime.shared.changeDateFormat(startDate, false)
//        let endDateText = MyDateTime.shared.changeDateFormat(MyDateTime.shared.dateCalculate(endDate, 1, false), false)
//        
//        switch (currentButtonFlag) {
//            
//        case .TODAY:
//            displayText = startDate
//        case .TWO_DAYS:
//            fallthrough
//        case .THREE_DAYS:
//            displayText = "\(startDateText) ~ \(endDateText)"
//        }
//        
//        todayDisplay.text = displayText
//    }
//    
//    func setUI() {
//        maxValue.text = String(max)
//        minValue.text = String(min)
//        avgValue.text = String(avg)
//        diffMin.text = "-\(avg - min)"
//        diffMax.text = "+\(max - avg)"
//    }
//    
//    func initUI() {
//        lineChartView.clear()
//        
//        min = 70
//        max = 0
//        avg = 0
//        avgSum = 0
//        avgCnt = 0
//        
//        maxValue.text = "0"
//        minValue.text = "0"
//        avgValue.text = "0"
//        diffMin.text = "-0"
//        diffMax.text = "+0"
//        
//        dissmissCalendar()
//        
//        switch (chartType) {
//        case .BPM:
    //            avgLabel.text = "unit_bpm_avg".localized()
    //            valueLabel.text = "unit_bpm_upper".localized()
//        case .HRV:
//            avgLabel.text = "unit_hrv_avg".localized()
//            valueLabel.text = "unit_hrv".localized()
//        default:
//            break
//        }
//    }
//}
