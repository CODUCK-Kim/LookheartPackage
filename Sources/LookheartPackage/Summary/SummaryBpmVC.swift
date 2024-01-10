
import Foundation
import UIKit
import DGCharts


@available(iOS 13.0, *)
class SummaryBpm : UIViewController, Refreshable {
    
    private let BPMDATA_FILENAME = "/BpmData.csv"
    private let YESTERDAY_BUTTON_FLAG = 1
    private let TOMORROW_BUTTON_FLAG = 2
    
    private let TODAY_FLAG = 1
    private let TWO_DAYS_FLAG = 2
    private let THREE_DAYS_FLAG = 3
    
    private var email = ""
    
    //    ----------------------------- Bpm Var -------------------    //
    private let dateFormatter = DateFormatter()
    
    private var minBpm = 70
    private var maxBpm = 0
    private var avgBpm = 0
    private var avgBpmSum = 0
    private var avgBpmCnt = 0
    
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
    
    private var bpmCalendar = Calendar.current
    
    private var buttonList:[UIButton] = []

    private var startBpmTime = [String]()
    private var endBpmTime = [String]()
    
    private var earliestStartTime = ""
    private var latestEndTime = ""
    
    private var xAxisTotal = 0
    private var startBpmTimeInMinutes = 0
    private var endBpmTimeInMinutes = 0
    
    private var timeTable: [String] = []
    
    private var bpmTimeCount = 0
    private var timeTableCount = 0
    
    private var targetBpmData: [Double] = []
    private var targetBpmTimeData: [String] = []
    
    private var twoDaysBpmData: [Double] = []
    private var twoDaysBpmTimeData: [String] = []
        
    private var threeDaysBpmData: [Double] = []
    private var threeDaysBpmTimeData: [String] = []
    
    private var targetBpmEntries = [ChartDataEntry]()
    private var twoDaysBpmEntries = [ChartDataEntry]()
    private var threeDaysBpmEntries = [ChartDataEntry]()
    
    //    ----------------------------- csv Var -------------------    //
    private var fileManager:FileManager = FileManager.default
    private var appendingPath = ""
    
    private lazy var documentsURL: URL = {
        return SummaryBpm.initializeDocumentsURL()
    }()
    
    private var currentDirectoryURL: URL {
        return documentsURL.appendingPathComponent("\(appendingPath)")
    }
    
    private var bpmDataFileURL: URL {
        return currentDirectoryURL.appendingPathComponent(BPMDATA_FILENAME)
    }
    
    // MARK: UI VAR
    private let safeAreaView = UIView()
    
    //    ----------------------------- Chart -------------------    //
    private lazy var bpmChartView = LineChartView().then {
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
    private let bottomLabel = UILabel().then {
        $0.isUserInteractionEnabled = true
    }
    
    private let topContents = UILabel().then {
        $0.isUserInteractionEnabled = true
    }
    
    private let middleContents = UILabel().then {
        $0.isUserInteractionEnabled = true
    }
    
    private let bottomContents = UILabel().then {
        $0.isUserInteractionEnabled = true
    }
    

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
    
    private lazy var yesterdayBpmButton = UIButton().then {
        $0.setImage(leftArrow, for: UIControl.State.normal)
        $0.tag = YESTERDAY_BUTTON_FLAG
        $0.addTarget(self, action: #selector(shiftDate(_:)), for: .touchUpInside)
    }
    
    private lazy var tomorrowBpmButton = UIButton().then {
        $0.setImage(rightArrow, for: UIControl.State.normal)
        $0.tag = TOMORROW_BUTTON_FLAG
        $0.addTarget(self, action: #selector(shiftDate(_:)), for: .touchUpInside)
    }
    
    // MARK: - Bottom
    private let leftBpmContents = UILabel()
    
    private let rightBpmContents = UILabel()
    
    private let centerBpmContents = UILabel()
    
    private let maxBpmLabel = UILabel().then {
        $0.text = "home_maxBpm".localized()
        $0.textColor = .lightGray
        $0.font = UIFont.systemFont(ofSize: 18, weight: .medium)
    }
    
    private let maxBpmValue = UILabel().then {
        $0.text = "0"
        $0.textColor = .lightGray
        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    }
    
    private let diffMaxBpm = UILabel().then {
        $0.text = "0"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.textColor = UIColor(red: 239/255, green: 80/255, blue: 123/255, alpha: 1.0)
    }
    
    private let minBpmLabel = UILabel().then {
        $0.text = "home_minBpm".localized()
        $0.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        $0.textColor = .lightGray
    }
    
    private let minBpmValue = UILabel().then {
        $0.text = "0"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.textColor = .lightGray
    }
    
    private let diffMinBpm = UILabel().then {
        $0.text = "0"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.textColor = UIColor(red: 83/255, green: 136/255, blue: 247/255, alpha: 1.0)
    }
    
    private let avgBpmLabel = UILabel().then {
        $0.text = "avgBPM".localized()
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }
    
    private let avgBpmValue = UILabel().then {
        $0.text = "0"
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }
    
    private let bpmLabel = UILabel().then {
        $0.text = "fragment_bpm".localized()
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }
    
    // MARK: -
    public static func initializeDocumentsURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // MARK: - VDL
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        initVar()
        addViews()
        initArray()
        todayBpmChart()

    }
    
    func refreshView() {
        initVar()
        addViews()
        initArray()
        todayBpmChart()
    }
    
    private func initVar() {
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
    func todayBpmChart() {
        setDisplayText(changeDateFormat("\(targetYear)-\(targetMonth)-\(targetDay)", false))
        
        if fileExists() {
            
            getFileData(
                path: "\(email)/\(targetYear)/\(targetMonth)/\(targetDay)",
                bpmData: &targetBpmData,
                timeData: &targetBpmTimeData)
            
            var bpmDataEntries = [ChartDataEntry]()
                        
            for i in 0 ..< targetBpmData.count - 1 {
                let bpmDataEntry = ChartDataEntry(x: Double(i), y: targetBpmData[i])
                bpmDataEntries.append(bpmDataEntry)
            }
            
            if bpmDataEntries.count == 0 {
                let bpmDataEntry = ChartDataEntry(x: Double(0), y: targetBpmData[0])
                bpmDataEntries.append(bpmDataEntry)
            }
            
            // set ChartData
            let bpmChartDataSet = chartDataSet(color: NSUIColor.GRAPH_BLUE, chartDataSet: LineChartDataSet(entries: bpmDataEntries, label: "fragment_bpm".localized()))
            
            removeSecond(targetBpmTimeData)
            
            setChart(chartData: LineChartData(dataSet: bpmChartDataSet),
                     maximum: 500,
                     axisMaximum: 200,
                     axisMinimum: 40)
            
            setBpmText()
            
        } else {
            // 파일 없음
        }
    }

    func twoDaysBpmChart() {
            
        setDisplayText("\(changeDateFormat("\(twoDaysTargetMonth)-\(twoDaysTargetDay)", true)) ~ \(changeDateFormat("\(targetMonth)-\(targetDay)", true))")
        
        if fileExists() {
            
            // TODAY Data
            getFileData(
                path: "\(email)/\(targetYear)/\(targetMonth)/\(targetDay)",
                bpmData: &targetBpmData,
                timeData: &targetBpmTimeData)
            
            // 2 DAYS Data
            getFileData(
                path: "\(email)/\(twoDaysTargetYear)/\(twoDaysTargetMonth)/\(twoDaysTargetDay)",
                bpmData: &twoDaysBpmData,
                timeData: &twoDaysBpmTimeData)
            
            // find start Time & end Time
            guard let startOfToday = targetBpmTimeData.first,
                  let endOfToday = targetBpmTimeData.last,
                  let startOfYesterday = twoDaysBpmTimeData.first,
                  let endOfYesterday = twoDaysBpmTimeData.last else {
                return
            }
            
            earliestStartTime = earlierTime(startOfToday, startOfYesterday)
            latestEndTime = earlierTime(endOfToday, endOfYesterday) == endOfToday ? endOfYesterday : endOfToday

            startBpmTime = earliestStartTime.components(separatedBy: ":")
            endBpmTime = latestEndTime.components(separatedBy: ":")

            // find difference Minutes
            startBpmTimeInMinutes = Int(startBpmTime[0])! * 60 + Int(startBpmTime[1])!
            endBpmTimeInMinutes = Int(endBpmTime[0])! * 60 + Int(endBpmTime[1])!

            xAxisTotal = (endBpmTimeInMinutes - startBpmTimeInMinutes) * 6
            
            // set timeTable
            setTimeTable(startBpmTime, false)

            // find start point
            var todayStart = findStartPoint(startOfToday.components(separatedBy: ":"))
            var twoDaysStart = findStartPoint(startOfYesterday.components(separatedBy: ":"))
            
            // last value
            let endOfTodayInt = timeToInt(endOfToday.components(separatedBy: ":"))
            let endOfYesterdayInt = timeToInt(endOfYesterday.components(separatedBy: ":"))
            
            // today's data
            processBpmData(timeData: targetBpmTimeData,
                           bpmData: targetBpmData,
                           endTimeInt: endOfTodayInt,
                           entries: &targetBpmEntries,
                           startIndex: &todayStart)

            bpmTimeCount = 0    // Reset bpmTimeCount for yesterday's data

            // yesterday's data
            processBpmData(timeData: twoDaysBpmTimeData,
                           bpmData: twoDaysBpmData,
                           endTimeInt: endOfYesterdayInt,
                           entries: &twoDaysBpmEntries,
                           startIndex: &twoDaysStart)
                            
            // remove second
            setTimeTable(startBpmTime, true)
            
            // set Chart
            let todaysDate = changeDateFormat("\(targetMonth)-\(targetDay)", true)
            let twoDaysDate = changeDateFormat("\(twoDaysTargetMonth)-\(twoDaysTargetDay)", true)
            
            let todayBpmChartDataSet = chartDataSet(color: NSUIColor.GRAPH_RED, chartDataSet: LineChartDataSet(entries: targetBpmEntries, label: todaysDate))
            let twoDaysBpmChartDataSet = chartDataSet(color: NSUIColor.GRAPH_BLUE, chartDataSet: LineChartDataSet(entries: twoDaysBpmEntries, label: twoDaysDate))
                                                                
            let bpmChartDataSets: [LineChartDataSet] = [twoDaysBpmChartDataSet, todayBpmChartDataSet]
            
            setChart(chartData: LineChartData(dataSets: bpmChartDataSets),
                     maximum: 1000,
                     axisMaximum: 200,
                     axisMinimum: 40)
            
            setBpmText()
            
        } else {
            // 파일 없음
        }
    }
    
    func threeDaysBpmChart() {
        
        setDisplayText("\(changeDateFormat("\(threeDaysTargetMonth)-\(threeDaysTargetDay)", true)) ~ \(changeDateFormat("\(targetMonth)-\(targetDay)", true))")
        
        if fileExists() {
            // Today Data
            getFileData(
                path: "\(email)/\(targetYear)/\(targetMonth)/\(targetDay)",
                bpmData: &targetBpmData,
                timeData: &targetBpmTimeData)
            
            // 2 DAYS Data
            getFileData(
                path: "\(email)/\(twoDaysTargetYear)/\(twoDaysTargetMonth)/\(twoDaysTargetDay)",
                bpmData: &twoDaysBpmData,
                timeData: &twoDaysBpmTimeData)
            
            // 3 DAYS Data
            getFileData(
                path: "\(email)/\(threeDaysTargetYear)/\(threeDaysTargetMonth)/\(threeDaysTargetDay)",
                bpmData: &threeDaysBpmData,
                timeData: &threeDaysBpmTimeData)
            
            // find start Time & end Time
            guard let startOfToday = targetBpmTimeData.first,
                  let endOfToday = targetBpmTimeData.last,
                  let startOfYesterday = twoDaysBpmTimeData.first,
                  let endOfYesterday = twoDaysBpmTimeData.last,
                  let startOfTwoDaysAgo = threeDaysBpmTimeData.first,
                  let endOfTwoDaysAgo = threeDaysBpmTimeData.last else {
                return
            }
            
            var compareDates = earlierTime(startOfToday, startOfYesterday)
            earliestStartTime = earlierTime(compareDates, startOfTwoDaysAgo)
            
            compareDates = earlierTime(endOfToday, endOfYesterday) == endOfToday ? endOfYesterday : endOfToday
            latestEndTime = earlierTime(compareDates, endOfTwoDaysAgo) == compareDates ? endOfTwoDaysAgo : compareDates
            
            startBpmTime = earliestStartTime.components(separatedBy: ":")
            endBpmTime = latestEndTime.components(separatedBy: ":")
            
            // find difference Minutes
            startBpmTimeInMinutes = Int(startBpmTime[0])! * 60 + Int(startBpmTime[1])!
            endBpmTimeInMinutes = Int(endBpmTime[0])! * 60 + Int(endBpmTime[1])!
            
            xAxisTotal = (endBpmTimeInMinutes - startBpmTimeInMinutes) * 6
            
            // set timeTable
            setTimeTable(startBpmTime, false)
            
            // find start point
            var todayStart = findStartPoint(startOfToday.components(separatedBy: ":"))
            var twoDaysStart = findStartPoint(startOfYesterday.components(separatedBy: ":"))
            var threeDaysStart = findStartPoint(startOfTwoDaysAgo.components(separatedBy: ":"))
            
            // last value
            let endOfTodayInt = timeToInt(endOfToday.components(separatedBy: ":"))
            let endOfYesterdayInt = timeToInt(endOfYesterday.components(separatedBy: ":"))
            let endOfTwoDaysAgoInt = timeToInt(endOfTwoDaysAgo.components(separatedBy: ":"))
            
            // today's data
            processBpmData(timeData: targetBpmTimeData,
                           bpmData: targetBpmData,
                           endTimeInt: endOfTodayInt,
                           entries: &targetBpmEntries,
                           startIndex: &todayStart)
            
            bpmTimeCount = 0    // Reset bpmTimeCount for yesterday's data
            
            // yesterday's data
            processBpmData(timeData: twoDaysBpmTimeData,
                           bpmData: twoDaysBpmData,
                           endTimeInt: endOfYesterdayInt,
                           entries: &twoDaysBpmEntries,
                           startIndex: &twoDaysStart)
            
            bpmTimeCount = 0
            
            // twoDaysAgo's data
            processBpmData(timeData: threeDaysBpmTimeData,
                           bpmData: threeDaysBpmData,
                           endTimeInt: endOfTwoDaysAgoInt,
                           entries: &threeDaysBpmEntries,
                           startIndex: &threeDaysStart)
            
            // remove second
            setTimeTable(startBpmTime, true)
            
            // set Chart
            let todaysDate = changeDateFormat("\(targetMonth)-\(targetDay)", true)
            let twoDaysDate = changeDateFormat("\(twoDaysTargetMonth)-\(twoDaysTargetDay)", true)
            let threeDaysDate = changeDateFormat("\(threeDaysTargetMonth)-\(threeDaysTargetDay)", true)
            
            let todayBpmChartDataSet = chartDataSet(color: NSUIColor.GRAPH_RED, chartDataSet: LineChartDataSet(entries: targetBpmEntries, label: todaysDate))
            let twoDaysBpmChartDataSet = chartDataSet(color: NSUIColor.GRAPH_BLUE, chartDataSet: LineChartDataSet(entries: twoDaysBpmEntries, label: twoDaysDate))
            let threeDaysBpmChartDataSet = chartDataSet(color: NSUIColor.GRAPH_GREEN, chartDataSet: LineChartDataSet(entries: threeDaysBpmEntries, label: threeDaysDate))
            
            let bpmChartDataSets: [LineChartDataSet] = [threeDaysBpmChartDataSet, twoDaysBpmChartDataSet, todayBpmChartDataSet]
            
            setChart(chartData: LineChartData(dataSets: bpmChartDataSets),
                     maximum: 1000,
                     axisMaximum: 200,
                     axisMinimum: 40)
            
            setBpmText()
            
        } else {
            // 파일 없음
        }
    }
    
    // MARK: - CHART FUNC
    func getFileData(path: String, bpmData: inout [Double], timeData: inout [String]) {
        do {
            appendingPath = path
            let fileData = try String(contentsOf: bpmDataFileURL)
            let separatedData = fileData.components(separatedBy: .newlines)
            
            for i in 0 ..< separatedData.count - 1 {
                let row = separatedData[i]
                let columns = row.components(separatedBy: ",")
                let bpm = Double(columns[2].trimmingCharacters(in: .whitespacesAndNewlines))
                
                let time = columns[0].components(separatedBy: ":")
                let bpmTime = time[0] + ":" + time[1] + ":" + (time[safe: 2] ?? "00")
                
                calcMinMax(Int(bpm ?? 70))
                bpmData.append(bpm ?? 0.0)
                timeData.append(bpmTime)
            }
        } catch  {
            print("Error reading CSV file")
        }
    }
    
    func setTimeTable(_ startBpmTime: [String], _ removeSecond: Bool){
        if removeSecond {   timeTable = []  }
        
        var bpmHour = Int(startBpmTime[0]) ?? 0
        var bpmMinutes = Int(startBpmTime[1]) ?? 0
        var seconds = 0
        
        for _ in 0 ..< xAxisTotal {
            var time = ""
            if removeSecond {
                time = String(format: "%02d:%02d", bpmHour, bpmMinutes)
            } else {
                time = String(format: "%02d:%02d:%d", bpmHour, bpmMinutes, seconds)
            }
            timeTable.append(time)
            seconds = (seconds + 1) % 6
            
            if seconds == 0 {
                incrementTime(hour: &bpmHour, minute: &bpmMinutes)
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
        return (startTimeInMinutes - startBpmTimeInMinutes) * 6
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
    
    func processBpmData(timeData: [String], bpmData: [Double], endTimeInt: Int, entries: inout [ChartDataEntry], startIndex: inout Int) {
        var bpmTimeCount = 0
        for _ in 0 ..< xAxisTotal {
            if bpmTimeCount >= timeData.count || startIndex >= timeTable.count { break }
            
            var bpmTime = timeToInt(timeData[bpmTimeCount].components(separatedBy: ":"))
            let timePoint = timeToInt(timeTable[startIndex].components(separatedBy: ":"))
            
            if bpmTime == endTimeInt { break }
            
            if bpmTime == timePoint {
                entries.append(ChartDataEntry(x: Double(startIndex), y: bpmData[bpmTimeCount]))
                bpmTimeCount += 1
            } else if bpmTime < timePoint {
                entries.append(ChartDataEntry(x: Double(startIndex), y: bpmData[max(bpmTimeCount - 1, 0)]))
            }
            
            while bpmTimeCount < timeData.count && bpmTime == timePoint && bpmTime != endTimeInt {
                entries.append(ChartDataEntry(x: Double(startIndex), y: bpmData[bpmTimeCount]))
                bpmTimeCount += 1
                if bpmTimeCount < timeData.count {
                    bpmTime = timeToInt(timeData[bpmTimeCount].components(separatedBy: ":"))
                }
            }
            
            startIndex += 1
        }
    }
    
    func chartDataSet(color: NSUIColor, chartDataSet: LineChartDataSet) -> LineChartDataSet {
        chartDataSet.drawCirclesEnabled = false
        chartDataSet.setColor(color)
        chartDataSet.mode = .linear
        chartDataSet.lineWidth = 0.7
        chartDataSet.drawValuesEnabled = true
        
        return chartDataSet
    }
    
    func setChart(chartData: LineChartData, maximum: Double, axisMaximum: Double, axisMinimum: Double) {
        bpmChartView.data = chartData
        bpmChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: timeTable)
        bpmChartView.setVisibleXRangeMaximum(maximum)
        bpmChartView.leftAxis.axisMaximum = axisMaximum
        bpmChartView.leftAxis.axisMinimum = axisMinimum
        bpmChartView.data?.notifyDataChanged()
        bpmChartView.notifyDataSetChanged()
        bpmChartView.moveViewToX(0)
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
            twoDaysBpmChart()
        case THREE_DAYS_FLAG:
            threeDaysBpmChart()
        default:
            todayBpmChart()
        }
    }
    
    func dateCalculate(_ date: String, _ day: Int, _ shouldAdd: Bool) {
        guard let inputDate = dateFormatter.date(from: date) else { return }

        let dayValue = shouldAdd ? day : -day
        if let arrTargetDate = bpmCalendar.date(byAdding: .day, value: dayValue, to: inputDate) {
            
            let components = bpmCalendar.dateComponents([.year, .month, .day], from: arrTargetDate)
            
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
        if let arrTargetDate = bpmCalendar.date(byAdding: .day, value: -1, to: inputDate) {
            
            let components = bpmCalendar.dateComponents([.year, .month, .day], from: arrTargetDate)
            
            if let year = components.year, let month = components.month, let day = components.day {
                twoDaysTargetYear = "\(year)"
                twoDaysTargetMonth = String(format: "%02d", month)
                twoDaysTargetDay = String(format: "%02d", day)
                
                twoDaysTargetDate = "\(twoDaysTargetYear)-\(twoDaysTargetMonth)-\(twoDaysTargetDay)"
            }
        }
        // threeDays
        if let arrTargetDate = bpmCalendar.date(byAdding: .day, value: -2, to: inputDate) {
            
            let components = bpmCalendar.dateComponents([.year, .month, .day], from: arrTargetDate)
            
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
        return fileManager.fileExists(atPath: bpmDataFileURL.path)
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
    
    func setBpmText() {
        maxBpmValue.text = String(maxBpm)
        minBpmValue.text = String(minBpm)
        avgBpmValue.text = String(avgBpm)
        diffMinBpm.text = "-\(avgBpm - minBpm)"
        diffMaxBpm.text = "+\(maxBpm - avgBpm)"
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
    
    func calcMinMax(_ bpm: Int) {
        if (bpm != 0){
            if (minBpm > bpm){
                minBpm = bpm
            }
            if (maxBpm < bpm){
                maxBpm = bpm
            }

            avgBpmSum += bpm
            avgBpmCnt += 1
            avgBpm = avgBpmSum/avgBpmCnt
        }
    }
    
    func initArray() {
        
        bpmChartView.clear()
        
        minBpm = 70
        maxBpm = 0
        avgBpm = 0
        avgBpmCnt = 0
        avgBpmSum = 0
        
        earliestStartTime = ""
        latestEndTime = ""
        
        startBpmTimeInMinutes = 0
        endBpmTimeInMinutes = 0
        
        xAxisTotal = 0
        
        bpmTimeCount = 0
        timeTableCount = 0
        
        timeTable.removeAll()
        
        startBpmTime.removeAll()
        endBpmTime.removeAll()
        
        targetBpmData.removeAll()
        targetBpmTimeData.removeAll()
        
        twoDaysBpmData.removeAll()
        twoDaysBpmTimeData.removeAll()
        
        threeDaysBpmData.removeAll()
        threeDaysBpmTimeData.removeAll()
        
        targetBpmEntries.removeAll()
        twoDaysBpmEntries.removeAll()
        threeDaysBpmEntries.removeAll()
        
        maxBpmValue.text = "0"
        minBpmValue.text = "0"
        avgBpmValue.text = "0"
        diffMinBpm.text = "-0"
        diffMaxBpm.text = "+0"
        
    }
    
    // MARK: -
    func addViews() {
        
        let totalMultiplier = 4.0 // 1.0, 1.0, 2.0
        let singlePortion = 1.0 / totalMultiplier
        
        let screenWidth = UIScreen.main.bounds.width // Screen width
        let oneThirdWidth = screenWidth / 3.0
        
        view.addSubview(safeAreaView)
        safeAreaView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        view.addSubview(bpmChartView)
        bpmChartView.snp.makeConstraints { make in
            make.top.left.right.equalTo(safeAreaView)
            make.height.equalTo(safeAreaView).multipliedBy(5.5 / (5.5 + 4.5))
        }
        
        view.addSubview(bottomLabel)
        bottomLabel.snp.makeConstraints { make in
            make.top.equalTo(bpmChartView.snp.bottom)
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
        
        middleContents.addSubview(yesterdayBpmButton)
        yesterdayBpmButton.snp.makeConstraints { make in
            make.top.bottom.equalTo(middleContents)
            make.left.equalTo(middleContents).offset(10)
        }
        
        middleContents.addSubview(tomorrowBpmButton)
        tomorrowBpmButton.snp.makeConstraints { make in
            make.top.bottom.equalTo(middleContents)
            make.right.equalTo(middleContents).offset(-10)
        }
        
        // --------------------- bottomContents --------------------- //
        bottomContents.addSubview(centerBpmContents)
        centerBpmContents.snp.makeConstraints { make in
            make.top.bottom.centerX.equalTo(bottomContents)
            make.width.equalTo(oneThirdWidth)
        }
        
        bottomContents.addSubview(leftBpmContents)
        leftBpmContents.snp.makeConstraints { make in
            make.top.bottom.left.equalTo(bottomContents)
            make.width.equalTo(oneThirdWidth)
        }
        
        bottomContents.addSubview(rightBpmContents)
        rightBpmContents.snp.makeConstraints { make in
            make.top.bottom.right.equalTo(bottomContents)
            make.width.equalTo(oneThirdWidth)
        }
        
        // --------------------- centerBpmContents --------------------- //
        centerBpmContents.addSubview(avgBpmValue)
        avgBpmValue.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(centerBpmContents)
        }
        
        centerBpmContents.addSubview(avgBpmLabel)
        avgBpmLabel.snp.makeConstraints { make in
            make.bottom.equalTo(avgBpmValue.snp.top).offset(-10)
            make.centerX.equalTo(centerBpmContents)
        }
        
        
        centerBpmContents.addSubview(bpmLabel)
        bpmLabel.snp.makeConstraints { make in
            make.top.equalTo(avgBpmValue.snp.bottom).offset(10)
            make.centerX.equalTo(centerBpmContents)
        }
        
        // --------------------- leftBpmContents --------------------- //
        leftBpmContents.addSubview(minBpmValue)
        minBpmValue.snp.makeConstraints { make in
            make.centerX.equalTo(leftBpmContents)
            make.centerY.equalTo(avgBpmValue)
        }
        
        leftBpmContents.addSubview(minBpmLabel)
        minBpmLabel.snp.makeConstraints { make in
            make.centerX.equalTo(leftBpmContents)
            make.centerY.equalTo(avgBpmLabel)
        }
        
        
        leftBpmContents.addSubview(diffMinBpm)
        diffMinBpm.snp.makeConstraints { make in
            make.centerX.equalTo(leftBpmContents)
            make.centerY.equalTo(bpmLabel)
        }
        
        // --------------------- rightBpmContents --------------------- //
        rightBpmContents.addSubview(maxBpmValue)
        maxBpmValue.snp.makeConstraints { make in
            make.centerX.equalTo(rightBpmContents)
            make.centerY.equalTo(avgBpmValue)
        }
        
        rightBpmContents.addSubview(maxBpmLabel)
        maxBpmLabel.snp.makeConstraints { make in
            make.centerX.equalTo(rightBpmContents)
            make.centerY.equalTo(avgBpmLabel)
        }
    
        
        rightBpmContents.addSubview(diffMaxBpm)
        diffMaxBpm.snp.makeConstraints { make in
            make.centerX.equalTo(rightBpmContents)
            make.centerY.equalTo(bpmLabel)
        }
    }
    
}
