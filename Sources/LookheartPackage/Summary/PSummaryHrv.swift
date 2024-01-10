import UIKit
import DGCharts
import Foundation

import SnapKit
import Then

@available(iOS 13.0, *)
class PSummaryHrv : UIViewController, Refreshable {
    
    private let HRVDATA_FILENAME = "/BpmData.csv"
    private let YESTERDAY_BUTTON_FLAG = 1
    private let TOMORROW_BUTTON_FLAG = 2
    
    private let TODAY_FLAG = 1
    private let TWO_DAYS_FLAG = 2
    private let THREE_DAYS_FLAG = 3
    
    private var email = ""
    
    //    ----------------------------- hrv Var -------------------    //
    private let dateFormatter = DateFormatter()
    
    private var minHrv = 70
    private var maxHrv = 0
    private var avgHrv = 0
    private var avgHrvSum = 0
    private var avgHrvCnt = 0
    
    private var currentFlag = 0
    
    private var currentYear:String = ""
    private var currentMonth:String = ""
    private var currentDay:String = ""
    
    private var targetDate:String = ""
    private var targetYear:String = ""
    private var targetMonth:String = ""
    private var targetDay:String = ""
    
    private var twoDaysTargetDate:String = ""
    private var twoDaysTargetYear:String = ""
    private var twoDaysTargetMonth:String = ""
    private var twoDaysTargetDay:String = ""
    
    private var threeDaysTargetDate:String = ""
    private var threeDaysTargetYear:String = ""
    private var threeDaysTargetMonth:String = ""
    private var threeDaysTargetDay:String = ""
    
    private var hrvCalendar = Calendar.current
    
    private var buttonList:[UIButton] = []

    private var startHrvTime = [String]()
    private var endHrvTime = [String]()
    
    private var earliestStartTime = ""
    private var latestEndTime = ""
    
    private var xAxisTotal = 0
    private var startHrvTimeInMinutes = 0
    private var endHrvTimeInMinutes = 0
    
    private var timeTable: [String] = []
    
    private var hrvTimeCount = 0
    private var timeTableCount = 0
    
    private var targetHrvData: [Double] = []
    private var targetHrvTimeData: [String] = []
    
    private var twoDaysHrvData: [Double] = []
    private var twoDaysHrvTimeData: [String] = []
        
    private var threeDaysHrvData: [Double] = []
    private var threeDaysHrvTimeData: [String] = []
    
    private var targetHrvEntries = [ChartDataEntry]()
    private var twoDaysHrvEntries = [ChartDataEntry]()
    private var threeDaysHrvEntries = [ChartDataEntry]()
    
    //    ----------------------------- csv Var -------------------    //
    private var fileManager:FileManager = FileManager.default
    private var appendingPath = ""
    
    private lazy var documentsURL: URL = {
        return PSummaryHrv.initializeDocumentsURL()
    }()
    
    private var currentDirectoryURL: URL {
        return documentsURL.appendingPathComponent("\(appendingPath)")
    }
    
    private var hrvDataFileURL: URL {
        return currentDirectoryURL.appendingPathComponent(HRVDATA_FILENAME)
    }
    
    // MARK: - UI VAR
    private let safeAreaView = UIView()
    
    //    ----------------------------- Chart -------------------    //
    private lazy var hrvChartView = LineChartView().then {
        $0.noDataText = ""
        $0.xAxis.enabled = true
        $0.legend.font = .systemFont(ofSize: 15, weight: .bold)
        $0.xAxis.granularity = 1
        $0.xAxis.labelPosition = .bottom
        $0.xAxis.drawGridLinesEnabled = false
        $0.rightAxis.enabled = false
        $0.drawMarkers = false
        $0.dragEnabled = true
        $0.pinchZoomEnabled = false
        $0.doubleTapToZoomEnabled = false
        $0.highlightPerTapEnabled = false
    }
    
    //    ----------------------------- UILabel -------------------    //
    private let bottomLabel = UILabel().then {  $0.isUserInteractionEnabled = true  }
    
    private let topContents = UILabel().then {  $0.isUserInteractionEnabled = true  }
    
    private let middleContents = UILabel().then {    $0.isUserInteractionEnabled = true  }
    
    private let bottomContents = UILabel().then {   $0.isUserInteractionEnabled = true  }
    
    // MARK: - Top
    private lazy var todayButton = UIButton().then {
        $0.setTitle ("today".localized(), for: .normal )
        
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
        
        $0.tag = TODAY_FLAG
        $0.addTarget(self, action: #selector(selectDayButton(_:)), for: .touchUpInside)
    }
    
    private lazy var twoDaysButton = UIButton().then {
        $0.setTitle ("twoDays".localized(), for: .normal )
        
        $0.setTitleColor(.lightGray, for: .normal)
        $0.setTitleColor(.white, for: .selected)
        $0.setTitleColor(.lightGray, for: .disabled)
        
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        $0.setBackgroundColor(UIColor.MY_LIGHT_GRAY_BORDER, for: .normal)
        $0.setBackgroundColor(UIColor.MY_LIGHT_GRAY_BORDER, for: .disabled)
        $0.setBackgroundColor(UIColor.MY_BODY_STATE, for: .selected)
        
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 15
        
        $0.tag = TWO_DAYS_FLAG
        $0.addTarget(self, action: #selector(selectDayButton(_:)), for: .touchUpInside)
    }
    
    private lazy var threeDaysButton = UIButton().then {
        $0.setTitle ("threeDays".localized(), for: .normal )
        $0.setTitleColor(.lightGray, for: .normal)
        $0.setTitleColor(.white, for: .selected)
        $0.setTitleColor(.lightGray, for: .disabled)
        
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        $0.setBackgroundColor(UIColor.MY_LIGHT_GRAY_BORDER, for: .normal)
        $0.setBackgroundColor(UIColor.MY_LIGHT_GRAY_BORDER, for: .disabled)
        $0.setBackgroundColor(UIColor.MY_BODY_STATE, for: .selected)
        
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 15
        
        $0.tag = THREE_DAYS_FLAG
        $0.addTarget(self, action: #selector(selectDayButton(_:)), for: .touchUpInside)
    }
    
    
    // MARK: - Middle
    private lazy var todayDispalay = UILabel().then {
        $0.text = "\(currentYear)-\(currentMonth)-\(currentDay)"
        $0.textColor = .black
        $0.textAlignment = .center
        $0.baselineAdjustment = .alignCenters
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }
    
    private lazy var yesterdayHrvButton = UIButton().then {
        $0.setImage(leftArrow, for: UIControl.State.normal)
        $0.tag = YESTERDAY_BUTTON_FLAG
        $0.addTarget(self, action: #selector(shiftDate(_:)), for: .touchUpInside)
    }
    private lazy var tomorrowHrvButton = UIButton().then {
        $0.setImage(rightArrow, for: UIControl.State.normal)
        $0.tag = TOMORROW_BUTTON_FLAG
        $0.addTarget(self, action: #selector(shiftDate(_:)), for: .touchUpInside)
    }
    
    // MARK: - bottom Contents
    private let leftHrvContents = UILabel()
    
    private let rightHrvContents = UILabel()
    
    private let centerHrvContents = UILabel()
    
    private let maxHrvLabel = UILabel().then {
        $0.text = "home_maxBpm".localized()
        $0.textColor = .lightGray
        $0.font = UIFont.systemFont(ofSize: 18, weight: .medium)
    }
    
    private let maxHrvValue = UILabel().then {
        $0.text = "0"
        $0.textColor = .lightGray
        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    }
    
    private let diffMaxHrv = UILabel().then {
        $0.text = "0"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.textColor = UIColor(red: 239/255, green: 80/255, blue: 123/255, alpha: 1.0)
    }
    
    private let minHrvLabel = UILabel().then {
        $0.text = "home_minBpm".localized()
        $0.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        $0.textColor = .lightGray
    }
    
    private let minHrvValue = UILabel().then {
        $0.text = "0"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.textColor = .lightGray
    }
    
    private let diffMinHrv = UILabel().then {
        $0.text = "0"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.textColor = UIColor(red: 83/255, green: 136/255, blue: 247/255, alpha: 1.0)
    }
    
    private let avgHrvLabel = UILabel().then {
        $0.text = "avgHRV".localized()
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }
    
    private let avgHrvValue = UILabel().then {
        $0.text = "0"
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }
    
    private let hrvLabel = UILabel().then {
        $0.text = "home_hrv_unit".localized()
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initVar()
        addViews()
        todayHrvChart()
        
    }
    
    func refreshView() {
        initVar()
        addViews()
        initArray()
        todayHrvChart()
    }
    
    func initVar(){
        
        let currentDate = MyDateTime.shared.getSplitDateTime(.DATE)
        
        email = UserProfileManager.shared.getEmail()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        currentFlag = TODAY_FLAG
        
        buttonList = [todayButton, twoDaysButton, threeDaysButton]
        
        currentYear = currentDate[0]
        currentMonth = currentDate[1]
        currentDay = currentDate[2]
        
        targetDate = MyDateTime.shared.getCurrentDateTime(.DATE)
        targetYear = currentYear
        targetMonth = currentMonth
        targetDay = currentDay
        
        setButtonColor(todayButton)
        setDays(targetDate)
    }
    
    // MARK: - CHART
    func todayHrvChart() {
        
        setDisplayText(changeDateFormat("\(targetYear)-\(targetMonth)-\(targetDay)", false))
        
        if fileExists() {
            
            getFileData(
                path: "\(email)/\(targetYear)/\(targetMonth)/\(targetDay)",
                hrvData: &targetHrvData,
                timeData: &targetHrvTimeData)
            
            var hrvDataEntries = [ChartDataEntry]()
            
            for i in 0 ..< targetHrvData.count - 1 {
                let hrvDataEntry = ChartDataEntry(x: Double(i), y: targetHrvData[i])
                hrvDataEntries.append(hrvDataEntry)
            }
            
            if hrvDataEntries.count == 0 {
                let hrvDataEntry = ChartDataEntry(x: Double(0), y: targetHrvData[0])
                hrvDataEntries.append(hrvDataEntry)
            }
            
            // set ChartData
            let hrvChartDataSet = chartDataSet(color: NSUIColor.GRAPH_BLUE, chartDataSet: LineChartDataSet(entries: hrvDataEntries, label: "home_hrv".localized()))
            
            removeSecond(targetHrvTimeData)
            
            setChart(chartData: LineChartData(dataSet: hrvChartDataSet),
                     maximum: 500,
                     axisMaximum: 150,
                     axisMinimum: 0.0)
            
            setHrvText()
            
        } else {
            // 파일 없음
        }
    }

    func twoDaysHrvChart() {
            
        setDisplayText("\(changeDateFormat("\(twoDaysTargetMonth)-\(twoDaysTargetDay)", true)) ~ \(changeDateFormat("\(targetMonth)-\(targetDay)", true))")
        
        if fileExists() {
            
            // TODAY Data
            getFileData(
                path: "\(email)/\(targetYear)/\(targetMonth)/\(targetDay)",
                hrvData: &targetHrvData,
                timeData: &targetHrvTimeData)
            
            // 2 DAYS Data
            getFileData(
                path: "\(email)/\(twoDaysTargetYear)/\(twoDaysTargetMonth)/\(twoDaysTargetDay)",
                hrvData: &twoDaysHrvData,
                timeData: &twoDaysHrvTimeData)
            
            // find start Time & end Time
            guard let startOfToday = targetHrvTimeData.first,
                  let endOfToday = targetHrvTimeData.last,
                  let startOfYesterday = twoDaysHrvTimeData.first,
                  let endOfYesterday = twoDaysHrvTimeData.last else {
                return
            }
            
            earliestStartTime = earlierTime(startOfToday, startOfYesterday)
            latestEndTime = earlierTime(endOfToday, endOfYesterday) == endOfToday ? endOfYesterday : endOfToday

            startHrvTime = earliestStartTime.components(separatedBy: ":")
            endHrvTime = latestEndTime.components(separatedBy: ":")

            // find difference Minutes
            startHrvTimeInMinutes = Int(startHrvTime[0])! * 60 + Int(startHrvTime[1])!
            endHrvTimeInMinutes = Int(endHrvTime[0])! * 60 + Int(endHrvTime[1])!

            xAxisTotal = (endHrvTimeInMinutes - startHrvTimeInMinutes) * 6
            
            // set timeTable
            setTimeTable(startHrvTime, false)

            // find start point
            var todayStart = findStartPoint(startOfToday.components(separatedBy: ":"))
            var twoDaysStart = findStartPoint(startOfYesterday.components(separatedBy: ":"))
            
            // last value
            let endOfTodayInt = timeToInt(endOfToday.components(separatedBy: ":"))
            let endOfYesterdayInt = timeToInt(endOfYesterday.components(separatedBy: ":"))
            
            // today's data
            processHrvData(timeData: targetHrvTimeData,
                           hrvData: targetHrvData,
                           endTimeInt: endOfTodayInt,
                           entries: &targetHrvEntries,
                           startIndex: &todayStart)

            hrvTimeCount = 0    // Reset HrvTimeCount for yesterday's data

            // yesterday's data
            processHrvData(timeData: twoDaysHrvTimeData,
                           hrvData: twoDaysHrvData,
                           endTimeInt: endOfYesterdayInt,
                           entries: &twoDaysHrvEntries,
                           startIndex: &twoDaysStart)
                            
            // remove second
            setTimeTable(startHrvTime, true)
            
            // set Chart
            let todaysDate = changeDateFormat("\(targetMonth)-\(targetDay)", true)
            let twoDaysDate = changeDateFormat("\(twoDaysTargetMonth)-\(twoDaysTargetDay)", true)
            
            let todayHrvChartDataSet = chartDataSet(color: NSUIColor.GRAPH_RED, chartDataSet: LineChartDataSet(entries: targetHrvEntries, label: todaysDate))
            let twoDaysHrvChartDataSet = chartDataSet(color: NSUIColor.GRAPH_BLUE, chartDataSet: LineChartDataSet(entries: twoDaysHrvEntries, label: twoDaysDate))
                                                                
            let hrvChartDataSets: [LineChartDataSet] = [twoDaysHrvChartDataSet, todayHrvChartDataSet]
            
            setChart(chartData: LineChartData(dataSets: hrvChartDataSets),
                     maximum: 1000,
                     axisMaximum: 150,
                     axisMinimum: 0.0)
            
            setHrvText()
            
        } else {
            // 파일 없음
        }
    }
    
    func threeDaysHrvChart() {
        
        setDisplayText("\(changeDateFormat("\(threeDaysTargetMonth)-\(threeDaysTargetDay)", true)) ~ \(changeDateFormat("\(targetMonth)-\(targetDay)", true))")
        
        if fileExists() {
            // Today Data
            getFileData(
                path: "\(email)/\(targetYear)/\(targetMonth)/\(targetDay)",
                hrvData: &targetHrvData,
                timeData: &targetHrvTimeData)
            
            // 2 DAYS Data
            getFileData(
                path: "\(email)/\(twoDaysTargetYear)/\(twoDaysTargetMonth)/\(twoDaysTargetDay)",
                hrvData: &twoDaysHrvData,
                timeData: &twoDaysHrvTimeData)
            
            // 3 DAYS Data
            getFileData(
                path: "\(email)/\(threeDaysTargetYear)/\(threeDaysTargetMonth)/\(threeDaysTargetDay)",
                hrvData: &threeDaysHrvData,
                timeData: &threeDaysHrvTimeData)
            
            // find start Time & end Time
            guard let startOfToday = targetHrvTimeData.first,
                  let endOfToday = targetHrvTimeData.last,
                  let startOfYesterday = twoDaysHrvTimeData.first,
                  let endOfYesterday = twoDaysHrvTimeData.last,
                  let startOfTwoDaysAgo = threeDaysHrvTimeData.first,
                  let endOfTwoDaysAgo = threeDaysHrvTimeData.last else {
                return
            }
            
            var compareDates = earlierTime(startOfToday, startOfYesterday)
            earliestStartTime = earlierTime(compareDates, startOfTwoDaysAgo)
            
            compareDates = earlierTime(endOfToday, endOfYesterday) == endOfToday ? endOfYesterday : endOfToday
            latestEndTime = earlierTime(compareDates, endOfTwoDaysAgo) == compareDates ? endOfTwoDaysAgo : compareDates
            
            startHrvTime = earliestStartTime.components(separatedBy: ":")
            endHrvTime = latestEndTime.components(separatedBy: ":")
            
            // find difference Minutes
            startHrvTimeInMinutes = Int(startHrvTime[0])! * 60 + Int(startHrvTime[1])!
            endHrvTimeInMinutes = Int(endHrvTime[0])! * 60 + Int(endHrvTime[1])!
            
            xAxisTotal = (endHrvTimeInMinutes - startHrvTimeInMinutes) * 6
            
            // set timeTable
            setTimeTable(startHrvTime, false)
            
            // find start point
            var todayStart = findStartPoint(startOfToday.components(separatedBy: ":"))
            var twoDaysStart = findStartPoint(startOfYesterday.components(separatedBy: ":"))
            var threeDaysStart = findStartPoint(startOfTwoDaysAgo.components(separatedBy: ":"))
            
            // last value
            let endOfTodayInt = timeToInt(endOfToday.components(separatedBy: ":"))
            let endOfYesterdayInt = timeToInt(endOfYesterday.components(separatedBy: ":"))
            let endOfTwoDaysAgoInt = timeToInt(endOfTwoDaysAgo.components(separatedBy: ":"))
            
            // today's data
            processHrvData(timeData: targetHrvTimeData,
                           hrvData: targetHrvData,
                           endTimeInt: endOfTodayInt,
                           entries: &targetHrvEntries,
                           startIndex: &todayStart)
            
            hrvTimeCount = 0    // Reset HrvTimeCount for yesterday's data
            
            // yesterday's data
            processHrvData(timeData: twoDaysHrvTimeData,
                           hrvData: twoDaysHrvData,
                           endTimeInt: endOfYesterdayInt,
                           entries: &twoDaysHrvEntries,
                           startIndex: &twoDaysStart)
            
            hrvTimeCount = 0
            
            // twoDaysAgo's data
            processHrvData(timeData: threeDaysHrvTimeData,
                           hrvData: threeDaysHrvData,
                           endTimeInt: endOfTwoDaysAgoInt,
                           entries: &threeDaysHrvEntries,
                           startIndex: &threeDaysStart)
            
            // remove second
            setTimeTable(startHrvTime, true)
            
            // set Chart
            let todaysDate = changeDateFormat("\(targetMonth)-\(targetDay)", true)
            let twoDaysDate = changeDateFormat("\(twoDaysTargetMonth)-\(twoDaysTargetDay)", true)
            let threeDaysDate = changeDateFormat("\(threeDaysTargetMonth)-\(threeDaysTargetDay)", true)
            
            let todayHrvChartDataSet = chartDataSet(color: NSUIColor.GRAPH_RED, chartDataSet: LineChartDataSet(entries: targetHrvEntries, label: todaysDate))
            let twoDaysHrvChartDataSet = chartDataSet(color: NSUIColor.GRAPH_BLUE, chartDataSet: LineChartDataSet(entries: twoDaysHrvEntries, label: twoDaysDate))
            let threeDaysHrvChartDataSet = chartDataSet(color: NSUIColor.GRAPH_GREEN, chartDataSet: LineChartDataSet(entries: threeDaysHrvEntries, label: threeDaysDate))
            
            let hrvChartDataSets: [LineChartDataSet] = [threeDaysHrvChartDataSet, twoDaysHrvChartDataSet, todayHrvChartDataSet]
            
            setChart(chartData: LineChartData(dataSets: hrvChartDataSets),
                     maximum: 1000,
                     axisMaximum: 150,
                     axisMinimum: 0.0)
            
            setHrvText()
            
        } else {
            // 파일 없음
        }
    }
    
    // MARK: - CHART FUNC
    func getFileData(path: String, hrvData: inout [Double], timeData: inout [String]) {

        do {
            appendingPath = path
            let fileData = try String(contentsOf: hrvDataFileURL)
            let separatedData = fileData.components(separatedBy: .newlines)
            
            for i in 0 ..< separatedData.count - 1 {
                let row = separatedData[i]
                let columns = row.components(separatedBy: ",")
                let hrv = Double(columns[4].trimmingCharacters(in: .whitespacesAndNewlines))
                
                let time = columns[0].components(separatedBy: ":")
                let hrvTime = time[0] + ":" + time[1] + ":" + (time[safe: 2] ?? "00")
                
                calcMinMax(Int(hrv ?? 70))
                hrvData.append(hrv ?? 0.0)
                timeData.append(hrvTime)
            }
        } catch  {
            print("Error reading CSV file")
        }
    }
    
    func setTimeTable(_ startHrvTime: [String], _ removeSecond: Bool){
        if removeSecond {   timeTable = []  }
        
        var hrvHour = Int(startHrvTime[0]) ?? 0
        var hrvMinutes = Int(startHrvTime[1]) ?? 0
        var seconds = 0
        
        for _ in 0 ..< xAxisTotal {
            var time = ""
            if removeSecond {
                time = String(format: "%02d:%02d", hrvHour, hrvMinutes)
            } else {
                time = String(format: "%02d:%02d:%d", hrvHour, hrvMinutes, seconds)
            }
            timeTable.append(time)
            seconds = (seconds + 1) % 6
            
            if seconds == 0 {
                incrementTime(hour: &hrvHour, minute: &hrvMinutes)
            }
        }
    }
    
    func removeSecond(_ startTime: [String]) {
        for time in startTime {
            let splitTime = time.split(separator: ":")
            timeTable.append("\(splitTime[0]):\(splitTime[1])")
        }
    }
    
    func incrementTime(hour: inout Int, minute: inout Int) {
        minute += 1
        if minute == 60 {
            hour += 1
            minute = 0
        }
    }
    
    func findStartPoint(_ startTime: [String]) -> Int {
        let startTimeInMinutes = Int(startTime[0])! * 60 + Int(startTime[1])!
        return (startTimeInMinutes - startHrvTimeInMinutes) * 6
    }
    
    func earlierTime(_ todayTime: String, _ yesterdayTime: String) -> String {
        let todayComponents = todayTime.components(separatedBy: ":")
        let yesterdayComponents = yesterdayTime.components(separatedBy: ":")

        let todayHour = Int(todayComponents[0])!
        let yesterdayHour = Int(yesterdayComponents[0])!
        let todayMinute = Int(todayComponents[1])!
        let yesterdayMinute = Int(yesterdayComponents[1])!

        if todayHour < yesterdayHour || (todayHour == yesterdayHour && todayMinute < yesterdayMinute) {
            return todayTime
        } else {
            return yesterdayTime
        }
    }
    
    func timeToInt(_ time: [String]) -> Int {
        let hour = Int(time[0]) ?? 0
        let minute = Int(time[1]) ?? 0
        let second = time[2].count == 2 ? Int(String(time[2].first!)) ?? 0 : Int(time[2]) ?? 0
        return hour * 3600 + minute * 60 + second
    }
    
    func processHrvData(timeData: [String], hrvData: [Double], endTimeInt: Int, entries: inout [ChartDataEntry], startIndex: inout Int) {
        var hrvTimeCount = 0
        for _ in 0 ..< xAxisTotal {
            if hrvTimeCount >= timeData.count || startIndex >= timeTable.count { break }
            
            var hrvTime = timeToInt(timeData[hrvTimeCount].components(separatedBy: ":"))
            let timePoint = timeToInt(timeTable[startIndex].components(separatedBy: ":"))
            
            if hrvTime == endTimeInt { break }
            
            if hrvTime == timePoint {
                entries.append(ChartDataEntry(x: Double(startIndex), y: hrvData[hrvTimeCount]))
                hrvTimeCount += 1
            } else if hrvTime < timePoint {
                entries.append(ChartDataEntry(x: Double(startIndex), y: hrvData[max(hrvTimeCount - 1, 0)]))
            }
            
            while hrvTimeCount < timeData.count && hrvTime == timePoint && hrvTime != endTimeInt {
                entries.append(ChartDataEntry(x: Double(startIndex), y: hrvData[hrvTimeCount]))
                hrvTimeCount += 1
                if hrvTimeCount < timeData.count {
                    hrvTime = timeToInt(timeData[hrvTimeCount].components(separatedBy: ":"))
                }
            }
            
            startIndex += 1
        }
    }
    
    func chartDataSet(color: NSUIColor, chartDataSet: LineChartDataSet) -> LineChartDataSet {
        chartDataSet.drawCirclesEnabled = false
        chartDataSet.setColor(color)
        chartDataSet.mode = .linear
        chartDataSet.lineWidth = 0.5
        chartDataSet.drawValuesEnabled = true
        
        return chartDataSet
    }
    
    func setChart(chartData: LineChartData, maximum: Double, axisMaximum: Double, axisMinimum: Double) {
        hrvChartView.data = chartData
        hrvChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: timeTable)
        hrvChartView.setVisibleXRangeMaximum(maximum)
        hrvChartView.leftAxis.axisMaximum = axisMaximum
        hrvChartView.leftAxis.axisMinimum = axisMinimum
        hrvChartView.data?.notifyDataChanged()
        hrvChartView.notifyDataSetChanged()
        hrvChartView.moveViewToX(0)
    }
    
    func changeDateFormat(_ dateString: String, _ checkDate: Bool) -> String {
        var dateComponents = dateString.components(separatedBy: "-")
        
        if checkDate {
            dateComponents[0] = String(format: "%02d", Int(dateComponents[0])!)
            dateComponents[1] = String(format: "%02d", Int(dateComponents[1])!)
        } else {
            dateComponents[1] = String(format: "%02d", Int(dateComponents[1])!)
            dateComponents[2] = String(format: "%02d", Int(dateComponents[2])!)
        }

        return dateComponents.joined(separator: "-")
    }
    
    // MARK: -
    @objc func shiftDate(_ sender: UIButton) {
        
        switch(sender.tag) {
        case YESTERDAY_BUTTON_FLAG:
            dateCalculate(targetDate, 1, false)
        default:    // TOMORROW_BUTTON_FLAG
            dateCalculate(targetDate, 1, true)
        }
        
        viewChart(currentFlag)
    }
    
    @objc func selectDayButton(_ sender: UIButton) {
        switch(sender.tag) {
        case TWO_DAYS_FLAG:
            currentFlag = TWO_DAYS_FLAG
        case THREE_DAYS_FLAG:
            currentFlag = THREE_DAYS_FLAG
        default:
            currentFlag = TODAY_FLAG
        }
        
        viewChart(currentFlag)
        setButtonColor(sender)
    }
     
    func viewChart(_ tag: Int) {
        
        initArray()
        
        switch(tag) {
        case TWO_DAYS_FLAG:
            twoDaysHrvChart()
        case THREE_DAYS_FLAG:
            threeDaysHrvChart()
        default:
            todayHrvChart()
        }
    }
    
    func dateCalculate(_ date: String, _ day: Int, _ shouldAdd: Bool) {
        guard let inputDate = dateFormatter.date(from: date) else { return }

        let dayValue = shouldAdd ? day : -day
        if let hrvTargetDate = hrvCalendar.date(byAdding: .day, value: dayValue, to: inputDate) {
            
            let components = hrvCalendar.dateComponents([.year, .month, .day], from: hrvTargetDate)
            
            if let year = components.year, let month = components.month, let day = components.day {
                targetYear = "\(year)"
                targetMonth = String(format: "%02d", month)
                targetDay = String(format: "%02d", day)
                
                targetDate = "\(targetYear)-\(targetMonth)-\(targetDay)"
                
                setDays(targetDate) // set twoDays, threeDays
            }
        }
    }
    
    func setDays(_ date: String) {
        guard let inputDate = dateFormatter.date(from: date) else { return }
        
        // twoDays
        if let hrvTargetDate = hrvCalendar.date(byAdding: .day, value: -1, to: inputDate) {
            
            let components = hrvCalendar.dateComponents([.year, .month, .day], from: hrvTargetDate)
            
            if let year = components.year, let month = components.month, let day = components.day {
                twoDaysTargetYear = "\(year)"
                twoDaysTargetMonth = String(format: "%02d", month)
                twoDaysTargetDay = String(format: "%02d", day)
                
                twoDaysTargetDate = "\(twoDaysTargetYear)-\(twoDaysTargetMonth)-\(twoDaysTargetDay)"
            }
        }
        // threeDays
        if let hrvTargetDate = hrvCalendar.date(byAdding: .day, value: -2, to: inputDate) {
            
            let components = hrvCalendar.dateComponents([.year, .month, .day], from: hrvTargetDate)
            
            if let year = components.year, let month = components.month, let day = components.day {
                threeDaysTargetYear = "\(year)"
                threeDaysTargetMonth = String(format: "%02d", month)
                threeDaysTargetDay = String(format: "%02d", day)
                
                threeDaysTargetDate = "\(threeDaysTargetYear)-\(threeDaysTargetMonth)-\(threeDaysTargetDay)"
            }
        }
        
//        print("today : \(targetDate)")
//        print("twodays : \(twoDaysTargetDate)")
//        print("threedays : \(threeDaysTargetDate)")
    }
    
    func setDisplayText(_ dateText: String) {
        todayDispalay.text = dateText
    }
    
    func pathForDate(year: String, month: String, day: String) -> String {
        return "\(email)/\(year)/\(month)/\(day)"
    }

    func fileExistsAtPath(_ path: String) -> Bool {
        appendingPath = path
        return fileManager.fileExists(atPath: hrvDataFileURL.path)
    }

    func fileExists() -> Bool {
        let paths: [String]
        
        switch currentFlag {
        case TWO_DAYS_FLAG:
            paths = [
                pathForDate(year: targetYear, month: targetMonth, day: targetDay),
                pathForDate(year: twoDaysTargetYear, month: twoDaysTargetMonth, day: twoDaysTargetDay)
            ]
        case THREE_DAYS_FLAG:
            paths = [
                pathForDate(year: targetYear, month: targetMonth, day: targetDay),
                pathForDate(year: twoDaysTargetYear, month: twoDaysTargetMonth, day: twoDaysTargetDay),
                pathForDate(year: threeDaysTargetYear, month: threeDaysTargetMonth, day: threeDaysTargetDay)
            ]
        default:
            paths = [pathForDate(year: targetYear, month: targetMonth, day: targetDay)]
        }
        
        for path in paths {
            if !fileExistsAtPath(path) {
                return false
            }
        }
        
        return true
    }
    
    func setHrvText() {
        maxHrvValue.text = String(maxHrv)
        minHrvValue.text = String(minHrv)
        avgHrvValue.text = String(avgHrv)
        diffMinHrv.text = "-\(avgHrv - minHrv)"
        diffMaxHrv.text = "+\(maxHrv - avgHrv)"
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
    
    func calcMinMax(_ hrv: Int) {
        if (hrv != 0){
            if (minHrv > hrv){
                minHrv = hrv
            }
            if (maxHrv < hrv){
                maxHrv = hrv
            }

            avgHrvSum += hrv
            avgHrvCnt += 1
            avgHrv = avgHrvSum/avgHrvCnt
        }
    }
    
    func initArray() {
        
        hrvChartView.clear()
        
        minHrv = 70
        maxHrv = 0
        avgHrv = 0
        avgHrvCnt = 0
        avgHrvSum = 0
        
        earliestStartTime = ""
        latestEndTime = ""
        
        startHrvTimeInMinutes = 0
        endHrvTimeInMinutes = 0
        
        xAxisTotal = 0
        
        hrvTimeCount = 0
        timeTableCount = 0
        
        timeTable.removeAll()
        
        startHrvTime.removeAll()
        endHrvTime.removeAll()
        
        targetHrvData.removeAll()
        targetHrvTimeData.removeAll()
        
        twoDaysHrvData.removeAll()
        twoDaysHrvTimeData.removeAll()
        
        threeDaysHrvData.removeAll()
        threeDaysHrvTimeData.removeAll()
        
        targetHrvEntries.removeAll()
        twoDaysHrvEntries.removeAll()
        threeDaysHrvEntries.removeAll()
        
        maxHrvValue.text = "0"
        minHrvValue.text = "0"
        avgHrvValue.text = "0"
        diffMinHrv.text = "-0"
        diffMaxHrv.text = "+0"
        
    }
    
    public static func initializeDocumentsURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // MARK: - addViews
    func addViews() {
        
        let totalMultiplier = 4.0 // 1.0, 1.0, 2.0
        let singlePortion = 1.0 / totalMultiplier
        
        let screenWidth = UIScreen.main.bounds.width // Screen width
        let oneThirdWidth = screenWidth / 3.0
        
        view.addSubview(safeAreaView)
        safeAreaView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        view.addSubview(hrvChartView)
        hrvChartView.snp.makeConstraints { make in
            make.top.left.right.equalTo(safeAreaView)
            make.height.equalTo(safeAreaView).multipliedBy(5.5 / (5.5 + 4.5))
        }
        
        view.addSubview(bottomLabel)
        bottomLabel.snp.makeConstraints { make in
            make.top.equalTo(hrvChartView.snp.bottom)
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
            make.left.right.equalTo(bottomLabel)
            make.height.equalTo(bottomLabel).multipliedBy(singlePortion)
        }
        
        bottomLabel.addSubview(bottomContents)
        bottomContents.snp.makeConstraints { make in
            make.top.equalTo(middleContents.snp.bottom)
            make.left.right.bottom.equalTo(bottomLabel)
        }
        
        // --------------------- Top Contents --------------------- //
        topContents.addSubview(twoDaysButton)
        twoDaysButton.snp.makeConstraints { make in
            make.top.centerX.equalTo(topContents)
            make.bottom.equalTo(topContents).offset(-20)
            make.width.equalTo(oneThirdWidth - 30)
        }
        
        topContents.addSubview(todayButton)
        todayButton.snp.makeConstraints { make in
            make.top.equalTo(topContents)
            make.left.equalTo(safeAreaView).offset(10)
            make.bottom.equalTo(topContents).offset(-20)
            make.width.equalTo(oneThirdWidth - 30)
        }
        
        topContents.addSubview(threeDaysButton)
        threeDaysButton.snp.makeConstraints { make in
            make.top.equalTo(topContents)
            make.right.equalTo(safeAreaView).offset(-10)
            make.bottom.equalTo(topContents).offset(-20)
            make.width.equalTo(oneThirdWidth - 30)
        }
        
        // --------------------- middleContents --------------------- //
        middleContents.addSubview(todayDispalay)
        todayDispalay.snp.makeConstraints { make in
            make.top.bottom.centerX.equalTo(middleContents)
        }
        
        middleContents.addSubview(yesterdayHrvButton)
        yesterdayHrvButton.snp.makeConstraints { make in
            make.top.bottom.equalTo(middleContents)
            make.left.equalTo(middleContents).offset(10)
        }
        
        middleContents.addSubview(tomorrowHrvButton)
        tomorrowHrvButton.snp.makeConstraints { make in
            make.top.bottom.equalTo(middleContents)
            make.right.equalTo(middleContents).offset(-10)
        }
        
        // --------------------- bottomContents --------------------- //
        bottomContents.addSubview(centerHrvContents)
        centerHrvContents.snp.makeConstraints { make in
            make.top.bottom.centerX.equalTo(bottomContents)
            make.width.equalTo(oneThirdWidth)
        }
        
        bottomContents.addSubview(leftHrvContents)
        leftHrvContents.snp.makeConstraints { make in
            make.top.bottom.left.equalTo(bottomContents)
            make.width.equalTo(oneThirdWidth)
        }
        
        bottomContents.addSubview(rightHrvContents)
        rightHrvContents.snp.makeConstraints { make in
            make.top.bottom.right.equalTo(bottomContents)
            make.width.equalTo(oneThirdWidth)
        }
        
        // --------------------- centerBpmContents --------------------- //
        centerHrvContents.addSubview(avgHrvValue)
        avgHrvValue.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(centerHrvContents)
        }
        
        centerHrvContents.addSubview(avgHrvLabel)
        avgHrvLabel.snp.makeConstraints { make in
            make.bottom.equalTo(avgHrvValue.snp.top).offset(-10)
            make.centerX.equalTo(centerHrvContents)
        }
        
        
        centerHrvContents.addSubview(hrvLabel)
        hrvLabel.snp.makeConstraints { make in
            make.top.equalTo(avgHrvValue.snp.bottom).offset(10)
            make.centerX.equalTo(centerHrvContents)
        }
        
        // --------------------- leftBpmContents --------------------- //
        leftHrvContents.addSubview(minHrvValue)
        minHrvValue.snp.makeConstraints { make in
            make.centerX.equalTo(leftHrvContents)
            make.centerY.equalTo(avgHrvValue)
        }
        
        leftHrvContents.addSubview(minHrvLabel)
        minHrvLabel.snp.makeConstraints { make in
            make.centerX.equalTo(leftHrvContents)
            make.centerY.equalTo(avgHrvLabel)
        }
        
        
        leftHrvContents.addSubview(diffMinHrv)
        diffMinHrv.snp.makeConstraints { make in
            make.centerX.equalTo(leftHrvContents)
            make.centerY.equalTo(hrvLabel)
        }
        
        // --------------------- rightBpmContents --------------------- //
        rightHrvContents.addSubview(maxHrvValue)
        maxHrvValue.snp.makeConstraints { make in
            make.centerX.equalTo(rightHrvContents)
            make.centerY.equalTo(avgHrvValue)
        }
        
        rightHrvContents.addSubview(maxHrvLabel)
        maxHrvLabel.snp.makeConstraints { make in
            make.centerX.equalTo(rightHrvContents)
            make.centerY.equalTo(avgHrvLabel)
        }
            
        rightHrvContents.addSubview(diffMaxHrv)
        diffMaxHrv.snp.makeConstraints { make in
            make.centerX.equalTo(rightHrvContents)
            make.centerY.equalTo(hrvLabel)
        }
        
    }
}
