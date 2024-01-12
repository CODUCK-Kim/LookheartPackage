import UIKit
import DGCharts
import Foundation
import SnapKit
import Then

@available(iOS 13.0, *)
class SummaryStep : UIViewController, Refreshable {
    
    private let STEPDATA_FILENAME = "/calandDistanceData.csv"
    private let YESTERDAY_BUTTON_FLAG = 1
    private let TOMORROW_BUTTON_FLAG = 2
    
    private let MONTH_FORMAT = true
    private let YEAR_FORMAT = false
    
    private let PATH_DAY = true
    private let PATH_MONTH = false
    
    private let ADD_DATE = true
    private let MINUS_DATE = false
    
    private let DAY_FLAG = 1
    private let WEEK_FLAG = 2
    private let MONTH_FLAG = 3
    private let YEAR_FLAG = 4
    private var email = ""
    
    enum DateChangeType: Int {
        case day = 1
        case week = 2
        case month = 3
        case year = 4
    }
    
    //    ----------------------------- step Var -------------------    //
    private let dateFormatter = DateFormatter()

    private var fileDataExists = 0
    
    private var stepSum = 0
    private var distanceSum = 0
    
    private var resultStepSum = 0
    private var resultDistanceSum = 0
    
    private var currentFlag = 0
    
    private var preDate = ""
    private var splitPreDate:[Substring] = []
    
    private var currentYear:String = ""
    private var currentMonth:String = ""
    private var currentDay:String = ""
    
    private var targetDate:String = ""
    private var targetYear:String = ""
    private var targetMonth:String = ""
    private var targetDay:String = ""
    
    private var calendar = Calendar.current
    
    private var buttonList:[UIButton] = []

    private var timeTable: [String] = []

    private var targetStepData: [Double] = []
    private var targetDistanceData: [Double] = []
    private var targetTimeData: [String] = []
    
    //    ----------------------------- csv Var -------------------    //
    private var fileManager:FileManager = FileManager.default
    private var appendingPath = ""
    
    private lazy var documentsURL: URL = {
        return SummaryStep.initializeDocumentsURL()
    }()
    
    private var currentDirectoryURL: URL {
        return documentsURL.appendingPathComponent("\(appendingPath)")
    }
    
    private var arrDataFileURL: URL {
        return currentDirectoryURL.appendingPathComponent(STEPDATA_FILENAME)
    }
    
    // MARK: - UI VAR
    private let safeAreaView = UIView()
    
    //    ----------------------------- Chart -------------------    //
    private lazy var stepChartView = BarChartView().then {
        $0.legend.font = .systemFont(ofSize: 15, weight: .bold)
        $0.noDataText = ""
        $0.xAxis.labelPosition = .bottom
        $0.xAxis.enabled = true
        $0.xAxis.granularity = 1
        $0.xAxis.drawGridLinesEnabled = false
        $0.xAxis.centerAxisLabelsEnabled = true
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
    
    //    ----------------------------- UILabel -------------------    //
    private let bottomLabel = UILabel().then {  $0.isUserInteractionEnabled = true  }
    
    private let topContents = UILabel().then {  $0.isUserInteractionEnabled = true  }
    
    private let middleContents = UILabel().then {  $0.isUserInteractionEnabled = true  }
    
    private lazy var bottomContents = UIStackView(arrangedSubviews: [stepBackground, distanceBackground]).then {
        $0.axis = .vertical
        $0.distribution = .fillEqually // default
        $0.alignment = .fill // default
        $0.spacing = 5
    }

    private let stepValueContents = UILabel()
    
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
    
    private lazy var yearButton = UIButton().then {
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
    private lazy var todayDispalay = UILabel().then {
        $0.text = "\(currentYear)-\(currentMonth)-\(currentDay)"
        $0.textColor = .black
        $0.textAlignment = .center
        $0.baselineAdjustment = .alignCenters
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }
    
    private lazy var yesterdayButton = UIButton().then {
        $0.setImage(leftArrow, for: UIControl.State.normal)
        $0.tag = YESTERDAY_BUTTON_FLAG
        $0.addTarget(self, action: #selector(shiftDate(_:)), for: .touchUpInside)
    }
    private lazy var tomorrowButton = UIButton().then {
        $0.setImage(rightArrow, for: UIControl.State.normal)
        $0.tag = TOMORROW_BUTTON_FLAG
        $0.addTarget(self, action: #selector(shiftDate(_:)), for: .touchUpInside)
    }
    
    // MARK: - bottom Contents
    private lazy var stepBackground = UIStackView(arrangedSubviews: [stepLabel, stepProgress]).then {
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.alignment = .fill
        $0.spacing = 10
        $0.isLayoutMarginsRelativeArrangement = true
        $0.layoutMargins = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    }
    private lazy var distanceBackground = UIStackView(arrangedSubviews: [distanceLabel, distanceProgress]).then {
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.alignment = .fill
        $0.spacing = 10
        $0.isLayoutMarginsRelativeArrangement = true
        $0.layoutMargins = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    }
    private let stepProgress = UIProgressView().then {
        $0.trackTintColor = UIColor.MY_LIGHT_GRAY_BORDER
        $0.progressTintColor = UIColor.GRAPH_RED
        $0.progress = 0.0
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
    }
    private let distanceProgress = UIProgressView().then {
        $0.trackTintColor = UIColor.MY_LIGHT_GRAY_BORDER
        $0.progressTintColor = UIColor.MY_BLUE
        $0.progress = 0.0
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
    }
    
    private let stepLabel = UILabel().then {
        $0.text = "summaryStep".localized()
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        $0.textColor = .black
    }
    
    private let distanceLabel = UILabel().then {
        $0.text = "distance".localized()
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        $0.textColor = .black
    }
    
    private let targetStep = UILabel().then {
        $0.text = "stepValue".localized()
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        $0.textColor = .black
    }
    
    private let targetDistance = UILabel().then {
        $0.text = "distanceValue3".localized()
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        $0.textColor = .black
    }
    
    private let walkCount = UILabel().then {
        $0.text = "stepValue".localized()
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        $0.textColor = .black
    }
    
    private let walkDistance = UILabel().then {
        $0.text = "distanceValue3".localized()
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        $0.textColor = .black
    }
    
    private let bottomLine = UILabel().then {   $0.backgroundColor = .lightGray }
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initVar()
        addViews()
        dailyStepChart()
        
    }
    
    func refreshView() {
        initVar()
        initArray()
        addViews()
        dailyStepChart()
    }
    
    func initVar(){
        
        let currentDate = MyDateTime.shared.getSplitDateTime(.DATE)
        
        email = UserProfileManager.shared.getEmail()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        currentFlag = DAY_FLAG
        
        buttonList = [dayButton, weekButton, monthButton, yearButton]
        
        currentYear = currentDate[0]
        currentMonth = currentDate[1]
        currentDay = currentDate[2]
        
        targetDate = MyDateTime.shared.getCurrentDateTime(.DATE)
        targetYear = currentYear
        targetMonth = currentMonth
        targetDay = currentDay
        
        targetStep.text = "\(UserProfileManager.shared.getStep()) \("stepValue2".localized())"
        targetDistance.text = "\(UserProfileManager.shared.getDistance()) \("distanceValue2".localized())"
        
        setButtonColor(dayButton)
    }
    
    // MARK: - CHART
    func dailyStepChart() {
        
        setDisplayText(changeDateFormat("\(targetYear)-\(targetMonth)-\(targetDay)", YEAR_FORMAT))
        
        if fileExists() {
            
            getFileData(path: "\(email)/\(targetYear)/\(targetMonth)/\(targetDay)")
            displayChart()
            
            setUI(day: 1, stepSum: stepSum, distanceSum: distanceSum)
            
        } else {
            // 파일 없음
        }
    }

    func weeklyStepChart() {
        
        let monday = findMonday()
        
        dateCalculate(targetDate, monday, MINUS_DATE, .day)
        preDate = targetDate
        let mondayMonth = targetMonth
        let mondayDay = targetDay
        
        fetchDailyFileData(startDay: 0, numDay: 6)
        
        setDisplayText("\(changeDateFormat("\(mondayMonth).\(mondayDay)", MONTH_FORMAT)) ~ \(changeDateFormat("\(targetMonth).\(targetDay)", MONTH_FORMAT))")
        
        dateCalculate(preDate, monday, ADD_DATE, .day)
        
        if !(fileDataExists == 7) {
            displayChart()
            setUI(day: 7 - fileDataExists, stepSum: resultStepSum, distanceSum: resultDistanceSum)
        } else {
            // 파일 없음
        }
    }
    
    func monthlyStepChart() {
        
        setDisplayText(changeDateFormat("\(targetYear).\(targetMonth)", MONTH_FORMAT))
        
        var numDay = 0 // 해당 월에 며칠인지 확인하는 변수
        let firstDay = findFirstDayOfMonth(targetDate)! // 1일까지 찾는 변수
        
        if compareMonth() { numDay = Int(currentDay)!   }
        else {  numDay = findNumDay(targetDate)!    }
        
        dateCalculate(targetDate, firstDay, MINUS_DATE, .day)
        preDate = targetDate
        
        fetchDailyFileData(startDay: 1, numDay: numDay)
        
        dateCalculate(preDate, firstDay, ADD_DATE, .day)
        
        if !(fileDataExists == numDay) {
            displayChart()
            setUI(day: numDay - fileDataExists, stepSum: resultStepSum, distanceSum: resultDistanceSum)
        } else {
            // 파일 없음
        }
    }
    
    func yearlyStepChart() {
        
        var monthlyStep = 0
        var monthlyDistance = 0
        var fileExistsCheck = 0
        
        setDisplayText(targetYear)
        
        splitPreDate = targetDate.split(separator: "-")
        targetDate = "\(targetYear)-01-01"
        targetMonth = "01"
        targetDay = "01"
                
        for month in 1...12 {
            if monthDirExists() {
                
                let numberOfDaysInMonth = findNumDay(targetDate)!
                for day in 1...numberOfDaysInMonth {
                    
                    targetDate = "\(targetYear)-\(month)-\(day)"
                    if fileExists(){
                        getFileData(path: "\(email)/\(targetYear)/\(targetMonth)/\(targetDay)")
                        monthlyStep += stepSum
                        monthlyDistance += distanceSum
                        stepSum = 0
                        distanceSum = 0
                        
                        fileExistsCheck += 1
                    }
                    
                    if day != numberOfDaysInMonth {  dateCalculate(targetDate, 1, ADD_DATE, .day) }
                }
                
                resultStepSum += monthlyStep
                resultDistanceSum += monthlyDistance
                
                targetStepData.append(Double(monthlyStep))
                targetDistanceData.append(Double(monthlyDistance))
                targetTimeData.append(String(month))
                
                monthlyStep = 0
                monthlyDistance = 0
                
            } else {
                // 디렉토리 없음
                fileDataExists += 1
            }
            
            dateCalculate(targetDate, 1, ADD_DATE, .month)
        }
        
        if fileDataExists != 12 {
            displayChart()
            setUI(day: fileExistsCheck, stepSum: resultStepSum, distanceSum: resultDistanceSum)
        } else {
            // 데이터 없음
        }
        
        targetDate = splitPreDate.joined(separator: "-")
        targetYear = String(splitPreDate[0])
        targetMonth = String(splitPreDate[1])
        targetDay = String(splitPreDate[2])
    }
    
    // MARK: - CHART FUNC
    func getFileData(path: String) {

        do {
            appendingPath = path
            let fileData = try String(contentsOf: arrDataFileURL)
            let separatedData = fileData.components(separatedBy: .newlines)
            
            for i in 0 ..< separatedData.count {
                if separatedData[i].isEmpty {   break   }
                let row = separatedData[i]
                let columns = row.components(separatedBy: ",")
                
                let step = Double(columns[2].trimmingCharacters(in: .whitespacesAndNewlines))
                let distance = Double(columns[3].trimmingCharacters(in: .whitespacesAndNewlines))
                
                sumStepAndDistance(Int(step ?? 0), Int(distance ?? 0))

                if currentFlag == DAY_FLAG {
                    targetStepData.append(step ?? 0.0)
                    targetDistanceData.append(distance ?? 0.0)
                    targetTimeData.append(columns[0])
                }
            }
        } catch  {
            print("Error reading CSV file")
        }
    }
        
    func setUI(day: Int, stepSum: Int, distanceSum: Int){
        let stepGoal = UserProfileManager.shared.getStep()
        let distanceGaol = UserProfileManager.shared.getDistance()
        
        // Progress
        let dailyStepRatio = Double(stepSum) / Double(stepGoal * day)
        stepProgress.progress = Float(dailyStepRatio)
        
        let dailyDistanceRatio = (Double(distanceSum) / 1000.0) / Double(distanceGaol * day)
        distanceProgress.progress = Float(dailyDistanceRatio)
        
        // text
        targetStep.text = "\(stepGoal) \("stepValue2".localized())"
        walkCount.text = "\(stepSum) \("stepValue2".localized())"
        targetDistance.text = "\(distanceGaol) \("distanceValue2".localized())"
        walkDistance.text = "\(distanceSum) \("distanceM2".localized())"
    }
    
    func displayChart() {
        var stepEntry = [BarChartDataEntry]()
        var distanceEntry = [BarChartDataEntry]()
        
        for i in 0 ..< targetStepData.count {
            let stepDataEntry = BarChartDataEntry(x: Double(i), y: targetStepData[i])
            let distanceDataEntry = BarChartDataEntry(x: Double(i), y: targetDistanceData[i])
            stepEntry.append(stepDataEntry)
            distanceEntry.append(distanceDataEntry)
        }

        // set ChartData
        let stepChartDataSet = chartDataSet(color: NSUIColor.GRAPH_RED, chartDataSet: BarChartDataSet(entries: stepEntry, label: "step".localized()))
        let distanceChartDataSet = chartDataSet(color: NSUIColor.GRAPH_BLUE, chartDataSet: BarChartDataSet(entries: distanceEntry, label: "distanceM".localized()))
        
        let dataSets: [BarChartDataSet] = [stepChartDataSet, distanceChartDataSet]
        
        setChart(chartData: BarChartData(dataSets: dataSets),
                 labelCnt: targetStepData.count)
    }
    
    func fetchDailyFileData(startDay: Int, numDay: Int) {
        
        for i in startDay...numDay {
            if fileExists() {
                getFileData(path: "\(email)/\(targetYear)/\(targetMonth)/\(targetDay)")
                targetStepData.append(Double(stepSum))
                targetDistanceData.append(Double(distanceSum))
                currentFlag == WEEK_FLAG ? targetTimeData.append(weekDays[i]) : targetTimeData.append(String(i))
            } else {
                switch (currentFlag){
                case MONTH_FLAG:
                    fileDataExists += 1
                default: // WEEK_FLAG
                    targetStepData.append(0.0)
                    targetDistanceData.append(0.0)
                    targetTimeData.append(weekDays[i])
                    fileDataExists += 1
                }
            }
            
            resultStepSum += stepSum
            resultDistanceSum += distanceSum
            
            stepSum = 0
            distanceSum = 0

            if i != numDay {  dateCalculate(targetDate, 1, ADD_DATE, .day) }
        }
    }

    
    func chartDataSet(color: NSUIColor, chartDataSet: BarChartDataSet) -> BarChartDataSet {
        chartDataSet.setColor(color)
        chartDataSet.drawValuesEnabled = false
        
        return chartDataSet
    }
    
    func setChart(chartData: BarChartData, labelCnt: Int) {
        let groupSpace = 0.3
        let barSpace = 0.05
        let barWidth = 0.3
        
        chartData.barWidth = barWidth
        
        stepChartView.xAxis.axisMinimum = Double(0)
        stepChartView.xAxis.axisMaximum = Double(0) + chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace) * Double(targetStepData.count)  // group count : 2
        chartData.groupBars(fromX: Double(0), groupSpace: groupSpace, barSpace: barSpace)
        
        stepChartView.legend.font = .systemFont(ofSize: 15, weight: .bold)
        
        stepChartView.data = chartData
        stepChartView.xAxis.enabled = true
        stepChartView.xAxis.centerAxisLabelsEnabled = true
        stepChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: targetTimeData)
        stepChartView.xAxis.granularity = 1
        stepChartView.xAxis.setLabelCount(targetStepData.count, force: false)
        stepChartView.xAxis.labelPosition = .bottom
        stepChartView.xAxis.drawGridLinesEnabled = false
        
        stepChartView.leftAxis.granularityEnabled = true
        stepChartView.leftAxis.granularity = 1.0
        
        stepChartView.leftAxis.axisMinimum = 0
        stepChartView.rightAxis.enabled = false
        stepChartView.drawMarkers = false
        stepChartView.dragEnabled = false
        stepChartView.pinchZoomEnabled = false
        stepChartView.doubleTapToZoomEnabled = false
        stepChartView.highlightPerTapEnabled = false
        
        stepChartView.data?.notifyDataChanged()
        stepChartView.notifyDataSetChanged()
        stepChartView.moveViewToX(0)
    
    }
    
    func changeDateFormat(_ dateString: String, _ checkDate: Bool) -> String {
        var dateComponents = checkDate == YEAR_FORMAT ? dateString.components(separatedBy: "-") : dateString.components(separatedBy: ".")
        
        if checkDate {  // month.day
            if !(dateComponents[0].count > 2) { // year.month check
                dateComponents[0] = String(format: "%02d", Int(dateComponents[0])!)
            }
            dateComponents[1] = String(format: "%02d", Int(dateComponents[1])!)
            return dateComponents.joined(separator: ".")
        } else {    // year-month-day
            dateComponents[1] = String(format: "%02d", Int(dateComponents[1])!)
            dateComponents[2] = String(format: "%02d", Int(dateComponents[2])!)
            
        }
        return checkDate == YEAR_FORMAT ? dateComponents.joined(separator: "-") : dateComponents.joined(separator: ".")
    }
    
    // MARK: -
    @objc func shiftDate(_ sender: UIButton) {
        let dateChangeType = DateChangeType(rawValue: currentFlag) ?? .day
        let dateDirection = sender.tag == YESTERDAY_BUTTON_FLAG ? MINUS_DATE : ADD_DATE
        
        switch dateChangeType {
        case .day:
            dateCalculate(targetDate, 1, dateDirection, .day)
        case .week:
            dateCalculate(targetDate, 7, dateDirection, .day)
        case .month:
            dateCalculate(targetDate, 1, dateDirection, .month)
        case .year:
            dateCalculate(targetDate, 1, dateDirection, .year)
        }
        
        viewChart(currentFlag)
    }
    
    @objc func selectDayButton(_ sender: UIButton) {
        switch(sender.tag) {
        case WEEK_FLAG:
            currentFlag = WEEK_FLAG
        case MONTH_FLAG:
            currentFlag = MONTH_FLAG
        case YEAR_FLAG:
            currentFlag = YEAR_FLAG
        default:
            currentFlag = DAY_FLAG
        }
        
        viewChart(currentFlag)
        setButtonColor(sender)
    }
     
    func viewChart(_ tag: Int) {
        
        initArray()
        
        switch(tag) {
        case WEEK_FLAG:
            weeklyStepChart()
        case MONTH_FLAG:
            monthlyStepChart()
        case YEAR_FLAG:
            yearlyStepChart()
        default:
            dailyStepChart()
        }
    }
    
    func dateCalculate(_ date: String, _ day: Int, _ shouldAdd: Bool, _ type: Calendar.Component) {
        
        guard let inputDate = dateFormatter.date(from: date) else { return }
        let dayValue = shouldAdd ? day : -day
        if let stepTargetDate = calendar.date(byAdding: type, value: dayValue, to: inputDate) {
            
            let components = calendar.dateComponents([.year, .month, .day], from: stepTargetDate)
            
            if let year = components.year, let month = components.month, let day = components.day {
                targetYear = "\(year)"
                targetMonth = String(format: "%02d", month)
                targetDay = String(format: "%02d", day)
                
                targetDate = "\(targetYear)-\(targetMonth)-\(targetDay)"
            }
        }
    }
    
    func setDisplayText(_ dateText: String) {
        todayDispalay.text = dateText
    }
    
    func pathForDate(year: String, month: String, day: String) -> String {
        return "\(email)/\(year)/\(month)/\(day)"
    }
    
    func fileExistsAtPath(_ path: String) -> Bool {
        appendingPath = path
        return fileManager.fileExists(atPath: arrDataFileURL.path)
    }

    func fileExists() -> Bool {
        let path = pathForDate(year: targetYear, month: targetMonth, day: targetDay)
        
        if !fileExistsAtPath(path) {
            return false
        }
        return true
    }
    
    func monthDirExists() -> Bool {
        let directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(email)/\(targetYear)/\(targetMonth)")
        var isDir: ObjCBool = false
        if fileManager.fileExists(atPath: directoryURL.path, isDirectory: &isDir) {
            if isDir.boolValue {    // 디렉토리 존재
                return true
            } else {    // 파일은 있지만 디렉토리가 아님
                return false
            }
        } else {    // 디렉토리 없음
            return false
        }
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
    
    func sumStepAndDistance(_ step: Int, _ distance: Int) {
        stepSum += step
        distanceSum += distance
    }
        
    func findWeekday() -> String? {
        var dateComponents = DateComponents()
        dateComponents.year = Int(targetYear)
        dateComponents.month = Int(targetMonth)
        dateComponents.day = Int(targetDay)
        
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
    
    
    func findNumDay(_ date: String) -> Int? {
        guard let inputDate = dateFormatter.date(from: date) else { return nil}
        if let range = calendar.range(of: .day, in: .month, for: inputDate) {
            return range.count
        } else {
            return nil
        }
    }
    
    func findFirstDayOfMonth(_ date: String) -> Int? {
        guard let inputDate = dateFormatter.date(from: date) else { return nil}
        let currentDayComponent = calendar.component(.day, from: inputDate)
        return  currentDayComponent - 1
    }
    
    func compareMonth() -> Bool {
        return currentYear == targetYear && currentMonth == targetMonth ? true : false
    }
    
    func initArray() {
        stepChartView.clear()

        stepSum = 0
        distanceSum = 0
        
        resultStepSum = 0
        resultDistanceSum = 0
        
        fileDataExists = 0
        
        preDate = ""
        
        timeTable.removeAll()

        targetStepData.removeAll()
        targetDistanceData.removeAll()
        targetTimeData.removeAll()
        
        setUI(day: 1, stepSum: stepSum, distanceSum: distanceSum)
    }
    
    public static func initializeDocumentsURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // MARK: - addViews
    func addViews() {
        
        let totalMultiplier = 4.0 // 1.0, 1.0, 2.0
        let singlePortion = 1.0 / totalMultiplier
        let screenWidth = UIScreen.main.bounds.width // Screen width
        let oneFourthWidth = screenWidth / 4.0
        
        view.addSubview(safeAreaView)
        safeAreaView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        view.addSubview(stepChartView)
        stepChartView.snp.makeConstraints { make in
            make.top.left.right.equalTo(safeAreaView)
            make.height.equalTo(safeAreaView).multipliedBy(5.5 / (5.5 + 4.5))
        }
        
        view.addSubview(bottomLabel)
        bottomLabel.snp.makeConstraints { make in
            make.top.equalTo(stepChartView.snp.bottom)
            make.left.right.bottom.equalTo(safeAreaView)
        }
        
        bottomLabel.addSubview(topContents)
        topContents.snp.makeConstraints { make in
            make.top.equalTo(bottomLabel).offset(10)
            make.left.equalTo(bottomLabel).offset(10)
            make.right.equalTo(bottomLabel).offset(-10)
            make.height.equalTo(bottomLabel).multipliedBy(singlePortion)
        }
        
        bottomLabel.addSubview(middleContents)
        middleContents.snp.makeConstraints { make in
            make.top.equalTo(topContents.snp.bottom)
            make.left.equalTo(bottomLabel).offset(10)
            make.right.equalTo(bottomLabel).offset(-10)
            make.height.equalTo(bottomLabel).multipliedBy(singlePortion)
        }
        
        bottomLabel.addSubview(bottomContents)
        bottomContents.snp.makeConstraints { make in
            make.top.equalTo(middleContents.snp.bottom)
            make.left.equalTo(bottomLabel).offset(20)
            make.right.equalTo(safeAreaView.snp.centerX).offset(40)
            make.bottom.equalTo(bottomLabel).offset(-5)
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
        middleContents.addSubview(yesterdayButton)
        yesterdayButton.snp.makeConstraints { make in
            make.top.left.bottom.equalTo(middleContents)
        }
        
        middleContents.addSubview(tomorrowButton)
        tomorrowButton.snp.makeConstraints { make in
            make.top.right.bottom.equalTo(middleContents)
        }
        
        middleContents.addSubview(todayDispalay)
        todayDispalay.snp.makeConstraints { make in
            make.top.centerX.bottom.equalTo(middleContents)
        }
        
        // --------------------- bottomContents --------------------- //
        bottomLabel.addSubview(stepValueContents)
        stepValueContents.snp.makeConstraints { make in
            make.top.equalTo(bottomContents)
            make.left.equalTo(bottomContents.snp.right)
            make.bottom.right.equalTo(safeAreaView)
        }
        
        stepValueContents.addSubview(walkCount)
        walkCount.snp.makeConstraints { make in
            make.centerX.equalTo(stepValueContents)
            make.centerY.equalTo(stepLabel)
        }
        
        stepValueContents.addSubview(targetStep)
        targetStep.snp.makeConstraints { make in
            make.centerX.equalTo(stepValueContents)
            make.centerY.equalTo(stepProgress)
        }
        
        stepValueContents.addSubview(walkDistance)
        walkDistance.snp.makeConstraints { make in
            make.centerX.equalTo(stepValueContents)
            make.centerY.equalTo(distanceLabel)
        }
        
        stepValueContents.addSubview(targetDistance)
        targetDistance.snp.makeConstraints { make in
            make.centerX.equalTo(stepValueContents)
            make.centerY.equalTo(distanceProgress)
        }
        
        stepValueContents.addSubview(bottomLine)
        bottomLine.snp.makeConstraints { make in
            make.centerY.equalTo(stepValueContents)
            make.left.equalTo(safeAreaView).offset(10)
            make.right.equalTo(safeAreaView).offset(-10)
            make.height.equalTo(1)
        }

    }
}
