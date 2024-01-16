import Foundation
import UIKit
import DGCharts

@available(iOS 13.0, *)
class BarChartVC : UIViewController {
    
    private var email = String()
    private var chartType: ChartType = .ARR
    
    enum DateType: Int {
        case DAY = 1
        case WEEK = 2
        case MONTH = 3
        case YEAR = 4
    }
    
    struct HourlyDataStruct {
        var arrCnt: Int = 0
        var step: Int = 0
        var distance: Int = 0
        var cal: Int = 0
        var activityCal: Int = 0
    }
    
    // ----------------------------- 상수 ------------------- //
    let weekDays = ["Monday".localized(), "Tuesday".localized(), "Wednesday".localized(), "Thursday".localized(), "Friday".localized(), "Saturday".localized(), "Sunday".localized()]
    
    private let YESTERDAY_BUTTON_FLAG = 1, TOMORROW_BUTTON_FLAG = 2
    private let DAY_FLAG = 1, WEEK_FLAG = 2, MONTH_FLAG = 3, YEAR_FLAG = 4
    
    private let PLUS_DATE = true, MINUS_DATE = false
    // 상수 END
    
    // ----------------------------- UI ------------------- //
    // 보여지는 변수
    // ARR
    private var arrCnt = 0  // 비정상 맥박 횟수
    // CAL
    private var burnTotalCal = 0, burnActivityCal = 0   // 소모 칼로리
    private var targetToTalCal = 0, targetActivityCal = 0   // 목표 칼로리
    // STEP
    private var step = 0, distance = 0   // 걸음, 이동 거리
    private var targetStep = 0, targetDistance = 0   // 목표 걸음, 이동 거리
    // UI VAR END
    
    // ----------------------------- DATE ------------------- //
    // 날짜 변수
    private let dateFormatter = DateFormatter()
    private let timeFormatter = DateFormatter()
    private var calendar = Calendar.current
    
    private var startDate = String()
    private var endDate = String()
    // DATE END
    
    // ----------------------------- CHART ------------------- //
    // 차트 관련 변수
    private var currentButtonFlag: DateType = .DAY   // 현재 버튼 플래그가 저장되는 변수
    private var buttonList:[UIButton] = []
    // CHART END
    
    // MARK: - UI VAR
    private let safeAreaView = UIView()
    
    //    ----------------------------- Loding Bar -------------------    //
    private lazy var activityIndicator = UIActivityIndicatorView().then {
        // indicator 스타일 설정
        $0.style = UIActivityIndicatorView.Style.large
    }
    
    //    ----------------------------- Chart -------------------    //
    // Cal, Step : $0.xAxis.centerAxisLabelsEnabled = true
    private lazy var barChartView = BarChartView().then {
        $0.legend.font = .systemFont(ofSize: 15, weight: .bold)
        $0.noDataText = ""
        $0.xAxis.enabled = true
        $0.xAxis.granularity = 1
        $0.xAxis.labelPosition = .bottom
        $0.xAxis.drawGridLinesEnabled = false
        $0.leftAxis.granularityEnabled = true
        $0.leftAxis.granularity = 1.0
        $0.leftAxis.axisMinimum = 0
        $0.rightAxis.enabled = false
        $0.drawMarkers = false
        $0.dragEnabled = false
        $0.pinchZoomEnabled = false
        $0.doubleTapToZoomEnabled = false
        $0.highlightPerTapEnabled = false
    }
    
    private let bottomContents = UILabel().then {  $0.isUserInteractionEnabled = true  }
    
    private let topContents = UILabel().then {  $0.isUserInteractionEnabled = true  }
    
    private let middleContents = UILabel().then {  $0.isUserInteractionEnabled = true  }
    
    // CAL, STEP
    private lazy var stepBottomContents = UIStackView(arrangedSubviews: [topBackground, bottomBackground]).then {
        $0.axis = .vertical
        $0.distribution = .fillEqually // default
        $0.alignment = .fill // default
        $0.spacing = 5
        $0.isHidden = true
    }
    
    // ARR
    private lazy var arrBottomContents = UIStackView(arrangedSubviews: [arrLabel, arrCntLabel]).then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.alignment = .fill
//        $0.isHidden = true
    }
    
    private let valueContents = UILabel()
    
    // MARK: - top Contents
    private lazy var dayButton = UIButton().then {
        $0.setTitle ("fragment_day".localized(), for: .normal )
        
        $0.setTitleColor(.lightGray, for: .normal)
        $0.setTitleColor(.white, for: .selected)
        $0.setTitleColor(.lightGray, for: .disabled)
        
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        $0.setBackgroundColor(UIColor.MY_LIGHT_GRAY_BORDER, for: .normal)
        $0.setBackgroundColor(UIColor.MY_LIGHT_GRAY_BORDER, for: .disabled)
        $0.setBackgroundColor(UIColor.MY_BODY_STATE, for: .selected)
        
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 15
        $0.isSelected = true
        
        $0.tag = DAY_FLAG
        $0.addTarget(self, action: #selector(selectDayButton(_:)), for: .touchUpInside)
    }
    
    private lazy var weekButton = UIButton().then {
        $0.setTitle ("fragment_week".localized(), for: .normal )
        
        $0.setTitleColor(.lightGray, for: .normal)
        $0.setTitleColor(.white, for: .selected)
        $0.setTitleColor(.lightGray, for: .disabled)
        
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        $0.setBackgroundColor(UIColor.MY_LIGHT_GRAY_BORDER, for: .normal)
        $0.setBackgroundColor(UIColor.MY_LIGHT_GRAY_BORDER, for: .disabled)
        $0.setBackgroundColor(UIColor.MY_BODY_STATE, for: .selected)
        
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 15
        
        $0.tag = WEEK_FLAG
        $0.addTarget(self, action: #selector(selectDayButton(_:)), for: .touchUpInside)
    }
    
    private lazy var monthButton = UIButton().then {
        $0.setTitle ("fragment_month".localized(), for: .normal )
        $0.setTitleColor(.lightGray, for: .normal)
        $0.setTitleColor(.white, for: .selected)
        $0.setTitleColor(.lightGray, for: .disabled)
        
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        $0.setBackgroundColor(UIColor.MY_LIGHT_GRAY_BORDER, for: .normal)
        $0.setBackgroundColor(UIColor.MY_LIGHT_GRAY_BORDER, for: .disabled)
        $0.setBackgroundColor(UIColor.MY_BODY_STATE, for: .selected)
                
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 15
        
        $0.tag = MONTH_FLAG
        $0.addTarget(self, action: #selector(selectDayButton(_:)), for: .touchUpInside)
    }
    
    lazy var yearButton = UIButton().then {
        $0.setTitle ("fragment_year".localized(), for: .normal )
        $0.setTitleColor(.lightGray, for: .normal)
        $0.setTitleColor(.white, for: .selected)
        $0.setTitleColor(.lightGray, for: .disabled)
        
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        $0.setBackgroundColor(UIColor.MY_LIGHT_GRAY_BORDER, for: .normal)
        $0.setBackgroundColor(UIColor.MY_LIGHT_GRAY_BORDER, for: .disabled)
        $0.setBackgroundColor(UIColor.MY_BODY_STATE, for: .selected)
        
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 15
        
        $0.tag = YEAR_FLAG
        $0.addTarget(self, action: #selector(selectDayButton(_:)), for: .touchUpInside)
    }
    
    // MARK: - middle Contents
    private lazy var todayDisplay = UILabel().then {
        $0.text = "-"
        $0.textColor = .black
        $0.textAlignment = .center
        $0.baselineAdjustment = .alignCenters
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }
    
    private lazy var yesterdayArrButton = UIButton().then {
        $0.setImage(leftArrow, for: UIControl.State.normal)
        $0.tag = YESTERDAY_BUTTON_FLAG
        $0.addTarget(self, action: #selector(shiftDate(_:)), for: .touchUpInside)
    }
    private lazy var tomorrowArrButton = UIButton().then {
        $0.setImage(rightArrow, for: UIControl.State.normal)
        $0.tag = TOMORROW_BUTTON_FLAG
        $0.addTarget(self, action: #selector(shiftDate(_:)), for: .touchUpInside)
    }
    
    // MARK: - bottom Contents
    //    ----------------------------- ARR -------------------    //
    private let arrLabel = UILabel().then {
        $0.text = "arrTimes".localized()
        $0.numberOfLines = 2
        $0.textColor = .darkGray
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        $0.textAlignment = .center
    }
    
    private let arrCntLabel = UILabel().then {
        $0.text = "0"
        $0.textColor = .darkGray
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        $0.textAlignment = .center
    }
    
    //    ----------------------------- STEP, CAL -------------------    //
    private lazy var topBackground = UIStackView(arrangedSubviews: [topTitleLabel, topProgress]).then {
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.alignment = .fill
        $0.spacing = 10
        $0.isLayoutMarginsRelativeArrangement = true
        $0.layoutMargins = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    }
    private lazy var bottomBackground = UIStackView(arrangedSubviews: [bottomTitleLabel, bottomProgress]).then {
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.alignment = .fill
        $0.spacing = 10
        $0.isLayoutMarginsRelativeArrangement = true
        $0.layoutMargins = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    }
    private let topProgress = UIProgressView().then {
        $0.trackTintColor = UIColor.MY_LIGHT_GRAY_BORDER
        $0.progressTintColor = UIColor.GRAPH_RED
        $0.progress = 0.0
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
    }
    private let bottomProgress = UIProgressView().then {
        $0.trackTintColor = UIColor.MY_LIGHT_GRAY_BORDER
        $0.progressTintColor = UIColor.MY_BLUE
        $0.progress = 0.0
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
    }
    
    private let topTitleLabel = UILabel().then {
        $0.text = "summaryStep".localized()
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        $0.textColor = .black
    }
    
    private let bottomTitleLabel = UILabel().then {
        $0.text = "distance".localized()
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        $0.textColor = .black
    }
    
    private let topGoal = UILabel().then {
        $0.text = "stepValue".localized()
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        $0.textColor = .black
    }
    
    private let bottomGoal = UILabel().then {
        $0.text = "distanceValue3".localized()
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        $0.textColor = .black
    }
    
    private let topValue = UILabel().then {
        $0.text = "stepValue".localized()
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        $0.textColor = .black
    }
    
    private let bottomValue = UILabel().then {
        $0.text = "distanceValue3".localized()
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        $0.textColor = .black
    }
    
    private let bottomLine = UILabel().then {   $0.backgroundColor = .lightGray }
    
    // MARK: - Button Event
    @objc func shiftDate(_ sender: UIButton) {
        
        startDate = setStartDate(startDate, sender.tag)
        endDate = setEndDate(startDate)
        
        getDataToServer(startDate, endDate, currentButtonFlag)
        setDisplayDateText()
    }
    
    @objc func selectDayButton(_ sender: UIButton) {
        switch (sender.tag) {
        case DAY_FLAG:
            currentButtonFlag = .DAY
        case WEEK_FLAG:
            currentButtonFlag = .WEEK
            startDate = MyDateTime.shared.dateCalculate(startDate, findMonday(), MINUS_DATE)
        case MONTH_FLAG:
            currentButtonFlag = .MONTH
            startDate = String(startDate.prefix(8)) + "01"
        case YEAR_FLAG:
            currentButtonFlag = .YEAR
            startDate = String(startDate.prefix(4)) + "-01-01"
        default:
            break
        }
        
        endDate = setEndDate(startDate)
        
        getDataToServer(startDate, endDate, currentButtonFlag)
        setDisplayDateText()
        setButtonColor(sender)
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initVar()
        
        addViews()
        
    }
    
    public func refreshView(_ type: ChartType) {
        chartType = type
        
        getDataToServer(startDate, endDate, currentButtonFlag)
    }
    
    func initVar() {
        //        email = UserProfileManager.shared.getEmail()
        email = "jhaseung@medsyslab.co.kr"          // test
        
        buttonList = [dayButton, weekButton, monthButton, yearButton]
        
        startDate = MyDateTime.shared.getCurrentDateTime(.DATE)
        endDate = MyDateTime.shared.dateCalculate(startDate, 1, PLUS_DATE)
        
        setDisplayDateText()
    }
    
    // MARK: - CHART FUNC
    private func viewChart(_ hourlyDataList: [HourlyData], _ type: DateType) {
        
        let dataDict = groupDataByDate(hourlyDataList)
//        var entriesAndTimeTable: ([BarChartDataEntry], [String])
        
//        switch (type) {
//        case .DAY:
//            entriesAndTimeTable = setDayChart(dataDict)
//        case .WEEK:
//            entriesAndTimeTable = setWeekChart(dataDict)
//        case .MONTH:
//            entriesAndTimeTable = setMonthChart(dataDict)
//        case .YEAR:
//            entriesAndTimeTable = setYearChart(dataDict)
//        }
        
//        var dataEntries = [BarChartDataEntry]()
//        var xValue = 0
//        for data in dataDict.1 {
//
//            dataEntries.append(BarChartDataEntry(x: Double(xValue), y: Double(data.arrCnt)))
//            xValue += 1
//        }
//        // set ChartData
//        let chartDataSet = chartDataSet(color: NSUIColor.MY_RED, chartDataSet: BarChartDataSet(entries: dataEntries, label: "arr".localized()))
//        
//        setChart(chartData: BarChartData(dataSet: chartDataSet), timeTable: dataDict.0, labelCnt: dataDict.0.count)
//        
//        let chartDataSet = chartDataSet(color: NSUIColor.MY_RED, chartDataSet: BarChartDataSet(entries: entriesAndTimeTable.0, label: "arr".localized()))
//        
//        setChart(chartData: BarChartData(dataSet: chartDataSet), timeTable: entriesAndTimeTable.1, labelCnt: entriesAndTimeTable.1.count)
    }
    
    private func setDayChart(_ dataDict : [String: (Int, [HourlyData])]) -> ([BarChartDataEntry], [String]) {
        
        var dataEntries = [BarChartDataEntry]()
        var timeTable:[String] = []
        var xValue = 0
        
        for (_, hourlyData) in dataDict {
            for data in hourlyData.1 {
                
                let yValue = Double(data.arrCnt) ?? 0.0
                dataEntries.append(BarChartDataEntry(x: Double(xValue), y: yValue))
                timeTable.append(data.hour)
                
                xValue += 1
            }
//            setArrCntUI(hourlyData.0)
        }
        
        return (dataEntries, timeTable)
    }
    
    
    private func setWeekChart(_ dataDict : [String: (Int, [HourlyData])]) -> ([BarChartDataEntry], [String]) {
        
        var dataEntries = [BarChartDataEntry]()
        var timeTable:[String] = []
        var xValue = 0
        
        var checkDate = startDate
        var dayIdx = 0
        var sumValue = 0
        
        let sortedDates = dataDict.keys.sorted()
        
        for i in 0..<7 {
            
            var yValue = 0.0
            
            if sortedDates.indices.contains(dayIdx) {
                let day = sortedDates[dayIdx]
                
                if checkDate == day {
                    yValue = Double(dataDict[day]?.0 ?? 0)
                    sumValue += Int(yValue)
                    dayIdx += 1
                }
            }
            
            let dataEntry = BarChartDataEntry(x: Double(xValue), y: yValue)
            
            dataEntries.append(dataEntry)
            timeTable.append(weekDays[i])
            
            checkDate = MyDateTime.shared.dateCalculate(checkDate, 1, true)
            xValue += 1
        }
        
        setArrCntUI(sumValue)
        return (dataEntries, timeTable)
    }
    
    private func setMonthChart(_ dataDict : [String: (Int, [HourlyData])]) -> ([BarChartDataEntry], [String]) {
        
        var dataEntries = [BarChartDataEntry]()
        var timeTable:[String] = []
        var xValue = 0
        var sumValue = 0
        
        let sortedDates = dataDict.keys.sorted()
        
        for date in sortedDates {
            
            let time = String(date.suffix(2)).first == "0" ? String(date.suffix(1)) : String(date.suffix(2))
            let yValue = Double(dataDict[date]?.0 ?? 0)
            let dataEntry = BarChartDataEntry(x: Double(xValue), y: yValue)
            
            dataEntries.append(dataEntry)
            timeTable.append(time)
            
            xValue += 1
            sumValue += Int(yValue)
        }
        
        setArrCntUI(sumValue)
        return (dataEntries, timeTable)
    }
    
    private func setYearChart(_ dataDict : [String: (Int, [HourlyData])]) -> ([BarChartDataEntry], [String]) {
        
        var dataEntries = [BarChartDataEntry]()
        var timeTable:[String] = []
        var xValue = 0
        var sumValue = 0
        
        var monthOfValue: [String : Int] = [:]
        
        for (date, hourlyData) in dataDict {
            monthOfValue[String(date.prefix(7)), default: 0] += hourlyData.0
        }
        
        
        let sortedDates = monthOfValue.keys.sorted()
        var monthIdx = 0
        
        for i in 0..<12 {
            
            var yValue = 0.0
            
            if sortedDates.indices.contains(monthIdx) {
                let month = Int(sortedDates[monthIdx].suffix(2)) ?? 1
                
                if i == month - 1 {
                    yValue = Double(monthOfValue[sortedDates[monthIdx]] ?? 0)
                    monthIdx += 1
                    sumValue += Int(yValue)
                }
            }
            
            let dataEntry = BarChartDataEntry(x: Double(xValue), y: yValue)
            dataEntries.append(dataEntry)
            timeTable.append(String(xValue + 1))
            
            xValue += 1
        }
        
        setArrCntUI(sumValue)
        return (dataEntries, timeTable)
    }
//    private func setDayChart(_ dataDict : [String: ([Int], [HourlyData])]) -> ([BarChartDataEntry], [BarChartDataEntry], [String]) {
//        
//        var dataEntries = [BarChartDataEntry]()
//        var dataEntries2 = [BarChartDataEntry]()
//        var timeTable:[String] = []
//        var xValue = 0
//        
//        for (_, hourlyData) in dataDict {
//            for data in hourlyData.1 {
//                
//                let yValue: Double
//                let yValue2: Double
//                
//                switch chartType {
//                case .ARR:
//                    yValue = Double(data.arrCnt) ?? 0.0
//                    dataEntries.append(BarChartDataEntry(x: Double(xValue), y: yValue))
//                default:
//                    yValue = (chartType == .CALORIE ? Double(data.cal) : Double(data.step)) ?? 0.0
//                    yValue2 = (chartType == .CALORIE ? Double(data.activityCal) : Double(data.distance)) ?? 0.0
//                    dataEntries.append(BarChartDataEntry(x: Double(xValue), y: yValue))
//                    dataEntries2.append(BarChartDataEntry(x: Double(xValue), y: yValue2))
//                }
//                
//                timeTable.append(data.hour)
//                
//                xValue += 1
//            }
////            setArrCntUI(hourlyData.0)
//        }
//        
//        return (dataEntries, dataEntries2, timeTable)
//    }
//    
//    
//    private func setWeekChart(_ dataDict : [String: ([Int], [HourlyData])]) -> ([BarChartDataEntry], [String]) {
//        
//        var dataEntries = [BarChartDataEntry]()
//        var timeTable:[String] = []
//        var xValue = 0
//        
//        var checkDate = startDate
//        var dayIdx = 0
//        var sumValue = 0
//        
//        let sortedDates = dataDict.keys.sorted()
//        
//        for i in 0..<7 {
//            
//            var yValue = 0.0
//            
//            if sortedDates.indices.contains(dayIdx) {
//                let day = sortedDates[dayIdx]
//                
//                if checkDate == day {
//                    yValue = Double(dataDict[day]?.0 ?? 0)
//                    sumValue += Int(yValue)
//                    dayIdx += 1
//                }
//            }
//            
//            let dataEntry = BarChartDataEntry(x: Double(xValue), y: yValue)
//            
//            dataEntries.append(dataEntry)
//            timeTable.append(weekDays[i])
//            
//            checkDate = MyDateTime.shared.dateCalculate(checkDate, 1, true)
//            xValue += 1
//        }
//        
//        setArrCntUI(sumValue)
//        return (dataEntries, timeTable)
//    }
//    
//    private func setMonthChart(_ dataDict : [String: ([Int], [HourlyData])]) -> ([BarChartDataEntry], [String]) {
//        
//        var dataEntries = [BarChartDataEntry]()
//        var timeTable:[String] = []
//        var xValue = 0
//        var sumValue = 0
//        
//        let sortedDates = dataDict.keys.sorted()
//        
//        for date in sortedDates {
//            
//            let time = String(date.suffix(2)).first == "0" ? String(date.suffix(1)) : String(date.suffix(2))
//            let yValue = Double(dataDict[date]?.0 ?? 0)
//            let dataEntry = BarChartDataEntry(x: Double(xValue), y: yValue)
//            
//            dataEntries.append(dataEntry)
//            timeTable.append(time)
//            
//            xValue += 1
//            sumValue += Int(yValue)
//        }
//        
//        setArrCntUI(sumValue)
//        return (dataEntries, timeTable)
//    }
//    
//    private func setYearChart(_ dataDict : [String: ([Int], [HourlyData])]) -> ([BarChartDataEntry], [String]) {
//        
//        var dataEntries = [BarChartDataEntry]()
//        var timeTable:[String] = []
//        var xValue = 0
//        var sumValue = 0
//        
//        var monthOfValue: [String : Int] = [:]
//        
//        for (date, hourlyData) in dataDict {
//            monthOfValue[String(date.prefix(7)), default: 0] += hourlyData.0
//        }
//        
//        
//        let sortedDates = monthOfValue.keys.sorted()
//        var monthIdx = 0
//        
//        for i in 0..<12 {
//            
//            var yValue = 0.0
//            
//            if sortedDates.indices.contains(monthIdx) {
//                let month = Int(sortedDates[monthIdx].suffix(2)) ?? 1
//                
//                if i == month - 1 {
//                    yValue = Double(monthOfValue[sortedDates[monthIdx]] ?? 0)
//                    monthIdx += 1
//                    sumValue += Int(yValue)
//                }
//            }
//            
//            let dataEntry = BarChartDataEntry(x: Double(xValue), y: yValue)
//            dataEntries.append(dataEntry)
//            timeTable.append(String(xValue + 1))
//            
//            xValue += 1
//        }
//        
//        setArrCntUI(sumValue)
//        return (dataEntries, timeTable)
//    }
    
    private func groupDataByDate(_ dataArray: [HourlyData]) {
        
        var hourlyDataDict:[String : HourlyDataStruct] = [:]
        
        for data in dataArray {
            let dateKey = currentButtonFlag == .DAY ? data.hour :
                          currentButtonFlag == .YEAR ? String(data.date.prefix(7)) : data.date
            
            if hourlyDataDict[dateKey] == nil {
                hourlyDataDict[dateKey] = HourlyDataStruct()
            }
            
            hourlyDataDict[dateKey]?.arrCnt += Int(data.arrCnt) ?? 0
            hourlyDataDict[dateKey]?.activityCal += Int(data.activityCal) ?? 0
            hourlyDataDict[dateKey]?.cal += Int(data.cal) ?? 0
            hourlyDataDict[dateKey]?.step += Int(data.step) ?? 0
            hourlyDataDict[dateKey]?.distance += Int(data.distance) ?? 0
        }
        
        print("====================================================================")
        for (date, data) in hourlyDataDict {
            print("date : \(date), \ndata : \(data)")
        }
    }
    
    // Calorie, Step
//    private func groupDataByDate(_ dataArray: [HourlyData]) -> [String: (Int, Int, [HourlyData])] {
//        let groupedData = dataArray.reduce(into: [String: (Int, Int, [HourlyData])]()) { dict, data in
//            let dateKey = String(data.date)
//            let sumValue = Int(chartType == .CALORIE ? data.cal : data.step) ?? 0
//            let sumValue2 = Int(chartType == .CALORIE ? data.activityCal : data.distance) ?? 0
//            
//            if var entry = dict[dateKey] {
//                entry.0 += sumValue
//                entry.1 += sumValue2
//                entry.2.append(data)    // HourlyData 배열에 추가
//                dict[dateKey] = entry
//            } else {
//                dict[dateKey] = (sumValue, sumValue2, [data]) // 새로운 항목 생성
//            }
//        }
//        
//        return groupedData
//    }
    
    // TEST
//    private func groupDataByDate(_ dataArray: [HourlyData]) -> [String: ([Int], [HourlyData])] {
//        let test = dataArray.filter { $0.date.contains("2024-01-15")}
//        print(test)
//        // 날짜별("YYYY-MM-DD")로 데이터 그룹화 및 총합 계산
//        let groupedData = dataArray.reduce(into: [String: ([Int], [HourlyData])]()) { dict, data in
//            let dateKey = String(data.date)
//            let sumValue = Int(chartType == .CALORIE ? data.cal : 
//                                chartType == .STEP ? data.step : data.arrCnt) ?? 0
//            let sumValue2 = Int(chartType == .CALORIE ? data.activityCal :
//                                    chartType == .STEP ? data.distance : "0") ?? 0
//            
//            // 기존에 그룹화된 데이터가 있다면 기존 총합에 더하고, 없다면 새로운 항목을 생성
//            if var entry = dict[dateKey] {
//                entry.0[0] += sumValue
//                entry.0[1] += sumValue2
//                entry.1.append(data)
//                dict[dateKey] = entry
//            } else {
//                dict[dateKey] = ([sumValue, sumValue2], [data]) // 새로운 항목 생성
//            }
//        }
//        return groupedData
//    }
    
    private func getDataToServer(_ startDate: String, _ endDate: String, _ type: DateType) {
        
        initUI()
        
        NetworkManager.shared.getHourlyDataToServer(id: email, startDate: startDate, endDate: endDate) { [self] result in
            switch(result){
            case .success(let hourlyDataList):
                
                viewChart(hourlyDataList, type)
                
            case .failure(let error):
                
                let errorMessage = NetworkErrorManager.shared.getErrorMessage(error as! NetworkError)
                toastMessage(errorMessage)
                activityIndicator.stopAnimating()
            }
        }
        
    }
    
    func chartDataSet(color: NSUIColor, chartDataSet: BarChartDataSet) -> BarChartDataSet {
        chartDataSet.setColor(color)
        chartDataSet.drawValuesEnabled = true
        chartDataSet.valueFormatter = CombinedValueFormatter()
        return chartDataSet
    }
    
    func setChart(chartData: BarChartData, timeTable: [String], labelCnt: Int) {
        barChartView.data = chartData
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: timeTable)
        barChartView.xAxis.setLabelCount(labelCnt, force: false)
        barChartView.data?.notifyDataChanged()
        barChartView.notifyDataSetChanged()
        barChartView.moveViewToX(0)
    }
    
    // MARK: - DATE FUNC
    func setStartDate(_ date: String, _ tag : Int) -> String {
        
        let flag = tag == TOMORROW_BUTTON_FLAG ? PLUS_DATE : MINUS_DATE
        
        switch (currentButtonFlag) {
        case .DAY:
            return MyDateTime.shared.dateCalculate(date, 1, flag)
        case .WEEK:
            startDate = MyDateTime.shared.dateCalculate(date, 7, flag)
            return MyDateTime.shared.dateCalculate(startDate, findMonday(), MINUS_DATE)
        case .MONTH:
            startDate = String(MyDateTime.shared.dateCalculate(date, 1, flag, .month).prefix(8))
            return startDate + "01"
        case .YEAR:
            startDate = String(MyDateTime.shared.dateCalculate(date, 1, flag, .year).prefix(4))
            return startDate + "-01-01"
        }
    }
    
    func setEndDate(_ date: String) -> String {
        switch (currentButtonFlag) {
        case .DAY:
            return MyDateTime.shared.dateCalculate(date, 1, PLUS_DATE)
        case .WEEK:
            return MyDateTime.shared.dateCalculate(date, 7, PLUS_DATE)
        case .MONTH:
            let numDay = MyDateTime.shared.findNumDay(date) ?? 30
            return MyDateTime.shared.dateCalculate(date, numDay, PLUS_DATE)
        case .YEAR:
            let lastDate = String(date.prefix(4)) + "-12-01"
            let numDay = MyDateTime.shared.findNumDay(lastDate) ?? 30
            return MyDateTime.shared.dateCalculate(lastDate, numDay, PLUS_DATE)
        }
    }
    
    func findMonday() -> Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        let weekdaySymbols = calendar.weekdaySymbols
        
        guard let weekdayName = findWeekday(),
              let weekdayIndex = weekdaySymbols.firstIndex(of: weekdayName) else {
            return 0
        }
        // 'calendar.firstWeekday'로 주의 시작 요일을 고려해 인덱스 조정
        // 그레고리안 캘린더에서 'firstWeekday'는 일반적으로 1(일요일)
        // 월요일을 0으로 만들기 위해, 인덱스에서 1을 빼고, 7로 나눈 나머지를 계산
        let mondayIndex = (weekdayIndex + 7 - calendar.firstWeekday) % 7
        return mondayIndex
    }
    
    func findWeekday() -> String? {
        var splitDate = startDate.split(separator: "-")
        var dateComponents = DateComponents()
        dateComponents.year = Int(splitDate[0])
        dateComponents.month = Int(splitDate[1])
        dateComponents.day = Int(splitDate[2])
        
        let calendar = Calendar.current
        
        if let specificDate = calendar.date(from: dateComponents) {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // 로케일 설정
            dateFormatter.dateFormat = "EEEE" // 요일의 전체 이름
            let weekdayName = dateFormatter.string(from: specificDate)

            return weekdayName
        } else {
            return nil
        }
    }
    
    // MARK: - UI
    private func setDisplayDateText() {
        var displayText = startDate
        let startDateText = MyDateTime.shared.changeDateFormat(startDate, false)
        let endDateText = MyDateTime.shared.changeDateFormat(MyDateTime.shared.dateCalculate(endDate, 1, false), false)
        
        switch (currentButtonFlag) {
            
        case .DAY:
            displayText = startDate
        case .WEEK:
            displayText = "\(startDateText) ~ \(endDateText)"
        case .MONTH:
            displayText = "\(startDate.prefix(7))"
        case .YEAR:
            displayText = "\(startDate.prefix(4))"
        }
        
        todayDisplay.text = displayText
    }
    
    func toastMessage(_ message: String) {
        // chartView의 중앙 좌표 계산
        let chartViewCenterX = barChartView.frame.size.width / 2
        let chartViewCenterY = barChartView.frame.size.height / 2

        // 토스트 컨테이너의 크기
        let containerWidth: CGFloat = barChartView.frame.width - 60
        let containerHeight: CGFloat = 35

        // 토스트 컨테이너가 chartView 중앙에 오도록 위치 조정
        let toastPositionX = chartViewCenterX - containerWidth / 2
        let toastPositionY = chartViewCenterY - containerHeight / 2
        
        ToastHelper.shared.showChartToast(self.view, message, position: CGPoint(x: toastPositionX, y: toastPositionY))

    }
    
    func setButtonColor(_ sender: UIButton) {
        for button in buttonList {
            if button == sender {
                button.isSelected = true
            } else {
                button.isSelected = false
            }
        }
    }
    
    private func initUI() {
        barChartView.clear()
        arrCntLabel.text = "0"
    }
    
    private func setArrCntUI(_ cnt : Int) {
        arrCntLabel.text = String(cnt)
    }
    
    // MARK: - addViews
    private func addViews() {
        let totalMultiplier = 4.0 // 1.0, 1.0, 2.0
        let singlePortion = 1.0 / totalMultiplier
        
        let screenWidth = UIScreen.main.bounds.width // Screen width
        let oneFourthWidth = screenWidth / 4.0
        
        view.addSubview(safeAreaView)
        safeAreaView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        view.addSubview(barChartView)
        barChartView.snp.makeConstraints { make in
            make.top.left.right.equalTo(safeAreaView)
            make.height.equalTo(safeAreaView).multipliedBy(5.5 / (5.5 + 4.5))
        }
        
        view.addSubview(bottomContents)
        bottomContents.snp.makeConstraints { make in
            make.top.equalTo(barChartView.snp.bottom)
            make.left.right.bottom.equalTo(safeAreaView)
        }
        
        bottomContents.addSubview(topContents)
        topContents.snp.makeConstraints { make in
            make.top.equalTo(bottomContents).offset(10)
            make.left.equalTo(bottomContents).offset(10)
            make.right.equalTo(bottomContents).offset(-10)
            make.height.equalTo(bottomContents).multipliedBy(singlePortion)
        }
        
        bottomContents.addSubview(middleContents)
        middleContents.snp.makeConstraints { make in
            make.top.equalTo(topContents.snp.bottom)
            make.left.equalTo(bottomContents).offset(10)
            make.right.equalTo(bottomContents).offset(-10)
            make.height.equalTo(bottomContents).multipliedBy(singlePortion)
        }
        
        // ARR Contents StackView
        bottomContents.addSubview(arrBottomContents)
        arrBottomContents.snp.makeConstraints { make in
            make.top.equalTo(middleContents.snp.bottom)
            make.left.right.bottom.equalTo(bottomContents)
        }
        
        // CAL, STEP Contents StackView
        bottomContents.addSubview(stepBottomContents)
        stepBottomContents.snp.makeConstraints { make in
            make.top.equalTo(middleContents.snp.bottom)
            make.left.equalTo(bottomContents).offset(20)
            make.right.equalTo(safeAreaView.snp.centerX).offset(40)
            make.bottom.equalTo(bottomContents).offset(-5)
        }
        
        // --------------------- topContents --------------------- //
        
        topContents.addSubview(weekButton)
        weekButton.snp.makeConstraints { make in
            make.top.equalTo(topContents)
            make.right.equalTo(topContents.snp.centerX).offset(-10)
            make.bottom.equalTo(topContents).offset(-20)
            make.width.equalTo(oneFourthWidth - 20)
        }
        
        topContents.addSubview(monthButton)
        monthButton.snp.makeConstraints { make in
            make.top.bottom.width.equalTo(weekButton)
            make.left.equalTo(topContents.snp.centerX).offset(10)
        }
        
        topContents.addSubview(dayButton)
        dayButton.snp.makeConstraints { make in
            make.top.bottom.width.equalTo(weekButton)
            make.left.equalTo(safeAreaView).offset(10)
        }
                
        topContents.addSubview(yearButton)
        yearButton.snp.makeConstraints { make in
            make.top.bottom.width.equalTo(weekButton)
            make.right.equalTo(safeAreaView).offset(-10)
        }
        
        // --------------------- middleContents --------------------- //
        
        middleContents.addSubview(yesterdayArrButton)
        yesterdayArrButton.snp.makeConstraints { make in
            make.top.left.bottom.equalTo(middleContents)
        }
        
        middleContents.addSubview(tomorrowArrButton)
        tomorrowArrButton.snp.makeConstraints { make in
            make.top.right.bottom.equalTo(middleContents)
        }
        
        middleContents.addSubview(todayDisplay)
        todayDisplay.snp.makeConstraints { make in
            make.top.centerX.bottom.equalTo(middleContents)
        }
     
        
        // --------------------- Cal, Step bottomContents --------------------- //
        bottomContents.addSubview(valueContents)
        valueContents.snp.makeConstraints { make in
            make.top.equalTo(bottomContents)
            make.left.equalTo(bottomContents.snp.right)
            make.bottom.right.equalTo(safeAreaView)
        }
    }
}
