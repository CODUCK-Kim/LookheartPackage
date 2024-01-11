import Foundation
import UIKit
import DGCharts


@available(iOS 13.0, *)
class LineChartVC : UIViewController, Refreshable {
    
    private var email = String()
    
    enum DateType {
        case TODAY_FLAG
        case TWO_DAYS_FLAG
        case THREE_DAYS_FLAG
    }
    
    // ----------------------------- TAG ------------------- //
    // 버튼 상수
    private let YESTERDAY_BUTTON_FLAG = 1
    private let TOMORROW_BUTTON_FLAG = 2
    
    private let TODAY_FLAG = 1
    private let TWO_DAYS_FLAG = 2
    private let THREE_DAYS_FLAG = 3
    
    private let PLUS_DATE = true
    private let MINUS_DATE = false
    // TAG END
    
    // ----------------------------- UI ------------------- //
    // 보여지는 변수
    private var min = 70
    private var max = 0
    private var avg = 0
    private var avgSum = 0
    private var avgCnt = 0
    // UI VAR END
    
    // ----------------------------- DATE ------------------- //
    // 날짜 변수
    private let dateFormatter = DateFormatter()
    private let timeFormatter = DateFormatter()
    private var calendar = Calendar.current
    
    private var startDate = String()
    private var endDate = String()
    
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
    // DATE END
    
    // ----------------------------- CHART ------------------- //
    // 차트 관련 변수
    private var currentButtonFlag = 0   // 현재 버튼 플래그가 저장되는 변수
    private var buttonList:[UIButton] = []
    
    private var startTime = [String]()
    private var endTime = [String]()
    
    private var earliestStartTime = String()
    private var latestEndTime = String()
    
    private var xAxisTotal = 0
    private var startTimeInMinutes = 0
    private var endTimeInMinutes = 0
    
    private var timeCount = 0
    private var timeTableCount = 0
    
    private var targetData: [Double] = []
    private var targetTimeData: [String] = []
    
    private var twoDaysData: [Double] = []
    private var twoDaysTimeData: [String] = []
        
    private var threeDaysData: [Double] = []
    private var threeDaysTimeData: [String] = []
    
    private var targetEntries = [ChartDataEntry]()
    private var twoDaysEntries = [ChartDataEntry]()
    private var threeDaysEntries = [ChartDataEntry]()
    // CHART END
    
    // MARK: UI VAR
    private let safeAreaView = UIView()
    
    private lazy var lineChartView = LineChartView().then {
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
    
    private let middleContents = UILabel().then {   $0.isUserInteractionEnabled = true  }
    
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
//        $0.addTarget(self, action: #selector(selectDayButton(_:)), for: .touchUpInside)
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
//        $0.addTarget(self, action: #selector(selectDayButton(_:)), for: .touchUpInside)
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
//        $0.addTarget(self, action: #selector(selectDayButton(_:)), for: .touchUpInside)
    }
    
    
    // MARK: - Middle
    private lazy var todayDispalay = UILabel().then {
        $0.textColor = .black
        $0.textAlignment = .center
        $0.baselineAdjustment = .alignCenters
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }
    
    private lazy var yesterdayBpmButton = UIButton().then {
        $0.setImage(leftArrow, for: UIControl.State.normal)
        $0.tag = YESTERDAY_BUTTON_FLAG
//        $0.addTarget(self, action: #selector(shiftDate(_:)), for: .touchUpInside)
    }
    
    private lazy var tomorrowBpmButton = UIButton().then {
        $0.setImage(rightArrow, for: UIControl.State.normal)
        $0.tag = TOMORROW_BUTTON_FLAG
//        $0.addTarget(self, action: #selector(shiftDate(_:)), for: .touchUpInside)
    }
    
    // MARK: - Bottom
    private let leftContents = UILabel()
    
    private let rightContents = UILabel()
    
    private let centerContents = UILabel()
    
    private let maxLabel = UILabel().then {
        $0.text = "home_maxBpm".localized()
        $0.textColor = .lightGray
        $0.font = UIFont.systemFont(ofSize: 18, weight: .medium)
    }
    
    private let maxValue = UILabel().then {
        $0.text = "0"
        $0.textColor = .lightGray
        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    }
    
    private let diffMax = UILabel().then {
        $0.text = "0"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.textColor = UIColor(red: 239/255, green: 80/255, blue: 123/255, alpha: 1.0)
    }
    
    private let minLabel = UILabel().then {
        $0.text = "home_minBpm".localized()
        $0.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        $0.textColor = .lightGray
    }
    
    private let minValue = UILabel().then {
        $0.text = "0"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.textColor = .lightGray
    }
    
    private let diffMin = UILabel().then {
        $0.text = "0"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.textColor = UIColor(red: 83/255, green: 136/255, blue: 247/255, alpha: 1.0)
    }
    
    private let avgLabel = UILabel().then {
        $0.text = "avgBPM".localized()
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }
    
    private let avgValue = UILabel().then {
        $0.text = "0"
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }
    
    private let valueLabel = UILabel().then {
        $0.text = "fragment_bpm".localized()
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }
    // ----------------------------- Constructor ------------------- //
    // 생성자
    var chartType: ChartType
    
    init(chartType: ChartType) {
        self.chartType = chartType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // Constructor END
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initVar()
        
        addViews()
        
        todayChart()
        
    }
    
    func refreshView() {
        
    }
    
    func initVar() {
//        email = UserProfileManager.shared.getEmail()
        
        // test
        email = "jhaseung@medsyslab.co.kr"
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        timeFormatter.dateFormat = "HH:mm:ss"
        
        currentButtonFlag = TODAY_FLAG
        
        buttonList = [todayButton, twoDaysButton, threeDaysButton]
        
        startDate = MyDateTime.shared.getCurrentDateTime(.DATE)
        endDate = dateCalculate(startDate, 2, MINUS_DATE)
        
    }
    
    // MARK: - CHART FUNC
    func todayChart() {
        
        startDate = "2024-01-09"
        
        getBpmDataToServer(startDate, dateCalculate(startDate, 2, PLUS_DATE), .TODAY_FLAG)
        
    }
    
    func viewChart(_ bpmDataList: [BpmData], _ type: DateType) {
        
        let dataDict = groupBpmDataByDate(bpmDataList)

        var chartDataSets: [LineChartDataSet] = []
        var entries: [String : [ChartDataEntry]] = [:]
        var bpmIdx: [String : Int] = [:]
        var preDateDict: [String : String] = [:]
        var timeTable: [String] = []
        
        for (date, dataForDate) in dataDict {
            
            bpmIdx[date] = 0
            entries[date] = [ChartDataEntry]()
            preDateDict[date] = ""
            
            for bpmData in dataForDate {
                if !timeTable.contains(bpmData.writeTime) {
                    timeTable.append(bpmData.writeTime) // 중복된 시간이 아닌 writeTime
                }
            }
        }
        
        timeTable.sort()    // 시간 정렬

        for i in 0..<timeTable.count {
            let time = timeTable[i]

            for (date, dataForDate) in dataDict {
                if let idx = bpmIdx[date] {
                    let bpmDataArray = dataForDate.filter { $0.writeTime == time }
                    
                    if !bpmDataArray.isEmpty {
                        let bpmValue = Double(bpmDataArray[0].bpm) ?? 0
                        let entry = ChartDataEntry(x: Double(idx), y: bpmValue)
                        entries[date]?.append(entry)
                    } else if i + 1 < timeTable.count { // 다음 time 존재 확인
                        let nextTime = timeTable[i + 1].prefix(7)
                        let nextTimeDataArray = dataForDate.filter { $0.writeTime.prefix(7) == nextTime }

                        if nextTimeDataArray.isEmpty {
                            let entry = ChartDataEntry(x: Double(idx), y: 70.0)
                            entries[date]?.append(entry)
                        }
                    }

                    bpmIdx[date] = idx + 1
                }
            }
        }
//        for time in timeTable {
//            for (date, dataForDate) in dataDict {
//                if let idx = bpmIdx[date] {
//                    let bpmDataArray = dataForDate.filter { $0.writeTime == time }
//                    
//                    if !bpmDataArray.isEmpty {
//                        let bpmValue = Double(bpmDataArray[0].bpm) ?? 0
//                        let entry = ChartDataEntry(x: Double(idx), y: bpmValue)
//                        entries[date]?.append(entry)
////                        bpmIdx[date] = idx + 1
//
//                    } else {
//                        let entry = ChartDataEntry(x: Double(idx), y: 70.0)
//                        entries[date]?.append(entry)
//                    }
//                    
//                    bpmIdx[date] = idx + 1
//                }
//            }
//        }
        
        for (date, entry) in entries {
            let chartDataSet = chartDataSet(color: NSUIColor.GRAPH_RED, chartDataSet: LineChartDataSet(entries: entry, label: date))
            chartDataSets.append(chartDataSet)
        }
        
        setChart(chartData: LineChartData(dataSets: chartDataSets),
                 maximum: 1000,
                 axisMaximum: 200,
                 axisMinimum: 40, 
                 timeTable: timeTable)
    }
    
    func groupBpmDataByDate(_ bpmDataArray: [BpmData]) -> [String: [BpmData]] {
        let groupedData = bpmDataArray.reduce(into: [String: [BpmData]]()) { dict, bpmData in
            let dateKey = String(bpmData.writeDate) // "YYYY-MM-DD" 기준 저장
            dict[dateKey, default: []].append(bpmData)
        }
        return groupedData
    }
    
//    func setChartData(_ bpmDataList: [BpmData], _ type: DateType) {
//        
//        switch (type) {
//        
//        case .TODAY_FLAG:
//            viewTodayChart(bpmDataList, type)
//        case .TWO_DAYS_FLAG:
//            viewTwoDaysChart(bpmDataList, type)
//        case .THREE_DAYS_FLAG:
//            viewThreeDaysChart(bpmDataList, )
//            
//        }
//    }
    
    func getBpmDataToServer(_ startDate: String, _ endDate: String, _ type: DateType) {
                        
        NetworkManager.shared.getBpmDataToServer(id: email, startDate: startDate, endDate: endDate) { result in
            switch(result){
            case .success(let bpmDataList):
                
                self.viewChart(bpmDataList, type)
                
            case .failure(let error):
                print("responseBpmData error : \(error)")
            }
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
    
    func setChart(chartData: LineChartData, maximum: Double, axisMaximum: Double, axisMinimum: Double, timeTable: [String]) {
        lineChartView.data = chartData
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: timeTable)
        lineChartView.setVisibleXRangeMaximum(maximum)
        lineChartView.leftAxis.axisMaximum = axisMaximum
        lineChartView.leftAxis.axisMinimum = axisMinimum
        lineChartView.data?.notifyDataChanged()
        lineChartView.notifyDataSetChanged()
        lineChartView.moveViewToX(0)
    }
    
    // MARK: - DATE FUNC
    func dateCalculate(_ date: String, _ day: Int, _ shouldAdd: Bool) -> String {
        guard let inputDate = dateFormatter.date(from: date) else { return date }

        let dayValue = shouldAdd ? day : -day
        if let arrTargetDate = calendar.date(byAdding: .day, value: dayValue, to: inputDate) {
            
            let components = calendar.dateComponents([.year, .month, .day], from: arrTargetDate)
            
            if let year = components.year, let month = components.month, let day = components.day {
                let year = "\(year)"
                let month = String(format: "%02d", month)
                let day = String(format: "%02d", day)
                
                return "\(year)-\(month)-\(day)"
            }
        }
        return date
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
        
        view.addSubview(lineChartView)
        lineChartView.snp.makeConstraints { make in
            make.top.left.right.equalTo(safeAreaView)
            make.height.equalTo(safeAreaView).multipliedBy(5.5 / (5.5 + 4.5))
        }
        
        view.addSubview(bottomLabel)
        bottomLabel.snp.makeConstraints { make in
            make.top.equalTo(lineChartView.snp.bottom)
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
        bottomContents.addSubview(centerContents)
        centerContents.snp.makeConstraints { make in
            make.top.bottom.centerX.equalTo(bottomContents)
            make.width.equalTo(oneThirdWidth)
        }
        
        bottomContents.addSubview(leftContents)
        leftContents.snp.makeConstraints { make in
            make.top.bottom.left.equalTo(bottomContents)
            make.width.equalTo(oneThirdWidth)
        }
        
        bottomContents.addSubview(rightContents)
        rightContents.snp.makeConstraints { make in
            make.top.bottom.right.equalTo(bottomContents)
            make.width.equalTo(oneThirdWidth)
        }
        
        // --------------------- centerBpmContents --------------------- //
        centerContents.addSubview(avgValue)
        avgValue.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(centerContents)
        }
        
        centerContents.addSubview(avgLabel)
        avgLabel.snp.makeConstraints { make in
            make.bottom.equalTo(avgValue.snp.top).offset(-10)
            make.centerX.equalTo(centerContents)
        }
        
        
        centerContents.addSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(avgValue.snp.bottom).offset(10)
            make.centerX.equalTo(centerContents)
        }
        
        // --------------------- leftBpmContents --------------------- //
        leftContents.addSubview(minValue)
        minValue.snp.makeConstraints { make in
            make.centerX.equalTo(leftContents)
            make.centerY.equalTo(avgValue)
        }
        
        leftContents.addSubview(minLabel)
        minLabel.snp.makeConstraints { make in
            make.centerX.equalTo(leftContents)
            make.centerY.equalTo(avgLabel)
        }
        
        
        leftContents.addSubview(diffMin)
        diffMin.snp.makeConstraints { make in
            make.centerX.equalTo(leftContents)
            make.centerY.equalTo(valueLabel)
        }
        
        // --------------------- rightBpmContents --------------------- //
        rightContents.addSubview(maxValue)
        maxValue.snp.makeConstraints { make in
            make.centerX.equalTo(rightContents)
            make.centerY.equalTo(avgValue)
        }
        
        rightContents.addSubview(maxLabel)
        maxLabel.snp.makeConstraints { make in
            make.centerX.equalTo(rightContents)
            make.centerY.equalTo(avgLabel)
        }
    
        
        rightContents.addSubview(diffMax)
        diffMax.snp.makeConstraints { make in
            make.centerX.equalTo(rightContents)
            make.centerY.equalTo(valueLabel)
        }
    }
}
