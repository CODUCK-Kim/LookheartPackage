import Foundation
import UIKit
import DGCharts


@available(iOS 13.0, *)
class LineChartVC : UIViewController, Refreshable {

    private var email = String()
    private var chartType: ChartType = .BPM
    
    enum DateType {
        case TODAY
        case TWO_DAYS
        case THREE_DAYS
    }
    
    // ----------------------------- TAG ------------------- //
    // 버튼 상수
    private let YESTERDAY_BUTTON_FLAG = 1
    private let TOMORROW_BUTTON_FLAG = 2
    
    private let TODAY_FLAG = 1
    private let TWO_DAYS_FLAG = 2
    private let THREE_DAYS_FLAG = 3
    
    private let PLUS_DATE = true, MINUS_DATE = false
    // TAG END
    
    // ----------------------------- UI ------------------- //
    // 보여지는 변수
    private var min = 70, max = 0, avg = 0, avgSum = 0, avgCnt = 0
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
    private var currentButtonFlag: DateType = .TODAY   // 현재 버튼 플래그가 저장되는 변수
    private var buttonList:[UIButton] = []
    // CHART END

    // MARK: UI VAR
    private let safeAreaView = UIView()
    
    //    ----------------------------- Loding Bar -------------------    //
    private lazy var activityIndicator = UIActivityIndicatorView().then {
        // indicator 스타일 설정
        $0.style = UIActivityIndicatorView.Style.large
    }
    
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
    private lazy var todayDisplay = UILabel().then {
        $0.text = "-"
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
    
    // MARK: - Button Evnet
    @objc func selectDayButton(_ sender: UIButton) {
        switch(sender.tag) {
        case TWO_DAYS_FLAG:
            currentButtonFlag = .TWO_DAYS
        case THREE_DAYS_FLAG:
            currentButtonFlag = .THREE_DAYS
        default:
            currentButtonFlag = .TODAY
        }
        
        startDate = dateCalculate(endDate, setDate(currentButtonFlag), MINUS_DATE)
        
        getBpmDataToServer(startDate, endDate, currentButtonFlag)
        setDisplayDateText()
        setButtonColor(sender)
    }
    
    @objc func shiftDate(_ sender: UIButton) {
        
        switch(sender.tag) {
        case YESTERDAY_BUTTON_FLAG:
            startDate = dateCalculate(startDate, 1, MINUS_DATE)
        default:    // TOMORROW_BUTTON_FLAG
            startDate = dateCalculate(startDate, 1, PLUS_DATE)
        }
        
        endDate = dateCalculate(startDate, setDate(currentButtonFlag), PLUS_DATE)
        
        getBpmDataToServer(startDate, endDate, currentButtonFlag)
        setDisplayDateText()
    }
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initVar()
        
        addViews()
        
        
    }
    
    public func refreshView(_ type: ChartType) {
        
        chartType = type
        
        getBpmDataToServer(startDate, endDate, currentButtonFlag)
        
    }
    
    func refreshView() {
        
    }
    
    func initVar() {
//        email = UserProfileManager.shared.getEmail()
        
        // test
        email = "jhaseung@medsyslab.co.kr"
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        timeFormatter.dateFormat = "HH:mm:ss"
        
        buttonList = [todayButton, twoDaysButton, threeDaysButton]
        
        startDate = MyDateTime.shared.getCurrentDateTime(.DATE)
        endDate = dateCalculate(startDate, setDate(.TODAY), PLUS_DATE)
        
        setDisplayDateText()
    }
    
    
    // MARK: - CHART FUNC
    func viewChart(_ bpmDataList: [BpmData], _ type: DateType) {
        
        let dataDict = groupBpmDataByDate(bpmDataList)
        var entries: [String : [ChartDataEntry]] = [:]
        var timeSets: Set<String> = []

        // setTimeTable
        for (date, dataForDate) in dataDict {
            
            entries[date] = [ChartDataEntry]()
            
            let timeSet = Set(dataForDate.map { $0.writeTime })
            timeSets.formUnion(timeSet)
        }
            
        let timeTable = timeSets.sorted()    // 시간 정렬

        // setDictionary
        let dataByTimeDict = setDictionary(dataDict)
        
        // setEntries
        entries = setEntries(entries: entries, timeTable: timeTable, dictionary: dataByTimeDict)
        
        // setChart
        let chartDataSets = setChartDataSets(entries: entries, type: type)
        setChart(chartData: LineChartData(dataSets: chartDataSets),
                 maximum: 1000,
                 axisMaximum: 200,
                 axisMinimum: 40, 
                 timeTable: timeTable)
        
        activityIndicator.stopAnimating()
        
    }
    
    
    func setDictionary(_ dataDict: [String : [BpmData]]) -> [String: [String: [BpmData]]] {
        // [ 날짜 : [ 시간 : [BpmData] ]
        var dataByTimeDict: [String: [String: [BpmData]]] = [:]
        
        for (date, dataForDate) in dataDict {
            var timeDict: [String: [BpmData]] = [:]
            for data in dataForDate {
                timeDict[data.writeTime, default: []].append(data)
            }
            dataByTimeDict[date] = timeDict
        }
        
        return dataByTimeDict
    }
    
    func setEntries(entries: [String : [ChartDataEntry]], timeTable: [String], dictionary: [String: [String: [BpmData]]]) -> [String : [ChartDataEntry]] {
        
        var resultEntries = entries

        for i in 0..<timeTable.count {
            let time = timeTable[i]

            for (date, timeDict) in dictionary {
                if let bpmDataArray = timeDict[time], !bpmDataArray.isEmpty {
                    // 데이터 존재
                    let value = chartType == .BPM ? Double(bpmDataArray[0].bpm) ?? 0 : Double(bpmDataArray[0].hrv) ?? 0
                    
                    calcMinMax(value)
                    
                    let entry = ChartDataEntry(x: Double(i), y: value)
                    resultEntries[date]?.append(entry)
                }
            }
        }
        return resultEntries
    }
    
    func groupBpmDataByDate(_ bpmDataArray: [BpmData]) -> [String: [BpmData]] {
        // 날짜별("YYYY-MM-DD")로 데이터 그룹화
        let groupedData = bpmDataArray.reduce(into: [String: [BpmData]]()) { dict, bpmData in
            let dateKey = String(bpmData.writeDate)
            dict[dateKey, default: []].append(bpmData)
        }
        return groupedData
    }
        
    func getBpmDataToServer(_ startDate: String, _ endDate: String, _ type: DateType) {
        
        activityIndicator.startAnimating()
        
        initUI()
        
        NetworkManager.shared.getBpmDataToServer(id: email, startDate: startDate, endDate: endDate) { result in
            switch(result){
            case .success(let bpmDataList):
                
                self.viewChart(bpmDataList, type)
                
            case .failure(let error):
                
                self.activityIndicator.stopAnimating()
                ToastHelper.shared.showToast(self.view, "serverErr".localized(), withDuration: 1.0, delay: 1.0, bottomPosition: false)
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
    
    func setChartDataSets(entries: [String : [ChartDataEntry]], type: DateType) -> [LineChartDataSet] {
        let graphColor = setGraphColor(type)
        var graphIdx = 0
        
        var chartDataSets: [LineChartDataSet] = []
        var dateChartDict: [String : LineChartDataSet] = [:]
        var dateText: [String] = []
        
        for (date, entry) in entries {
            let chartDataSet = chartDataSet(color: graphColor[graphIdx], chartDataSet: LineChartDataSet(entries: entry, label: changeDateFormat(date, false)))
            dateChartDict[date] = chartDataSet
            graphIdx += 1
        }
        
        // 시간순으로 정렬
        let sortedDates = dateChartDict.keys.sorted()
        for date in sortedDates {
            if let chartDataSet = dateChartDict[date] {
                chartDataSets.append(chartDataSet)
                dateText.append(date)
            }
        }
        
        setUI()
        
        return chartDataSets
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
    
    func setGraphColor(_ type : DateType) -> [UIColor] {
        switch (type) {
        case .TODAY:
            return [NSUIColor.GRAPH_RED]
        case .TWO_DAYS:
            return [NSUIColor.GRAPH_RED, NSUIColor.GRAPH_BLUE]
        case .THREE_DAYS:
            return [NSUIColor.GRAPH_RED, NSUIColor.GRAPH_BLUE, NSUIColor.GRAPH_GREEN]
        }
    }
    
    // MARK: - DATE FUNC
    func setDate(_ type : DateType) -> Int {
        switch (type) {
        case .TODAY:
            return 1
        case .TWO_DAYS:
            return 2
        case .THREE_DAYS:
            return 3
        }
    }
    
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
    
    func changeDateFormat(_ dateString: String, _ yearFlag: Bool) -> String {
        var dateComponents = dateString.components(separatedBy: "-")
        
        if yearFlag {
            dateComponents[0] = String(format: "%02d", Int(dateComponents[0])!)
            dateComponents[1] = String(format: "%02d", Int(dateComponents[1])!)
            return "\(dateComponents[0])-\(dateComponents[1])"
        } else {
            dateComponents[1] = String(format: "%02d", Int(dateComponents[1])!)
            dateComponents[2] = String(format: "%02d", Int(dateComponents[2])!)
            return "\(dateComponents[1])-\(dateComponents[2])"
        }
    }
    
    // MARK: - UI
    func setDisplayDateText() {
        var displayText = startDate
        let startDateText = changeDateFormat(startDate, false)
        let endDateText = changeDateFormat(dateCalculate(endDate, 1, false), false)
        
        switch (currentButtonFlag) {
            
        case .TODAY:
            displayText = startDate
        case .TWO_DAYS:
            fallthrough
        case .THREE_DAYS:
            displayText = "\(startDateText) ~ \(endDateText)"
        }
        
        todayDisplay.text = displayText
    }
    
    func setUI() {
        maxValue.text = String(max)
        minValue.text = String(min)
        avgValue.text = String(avg)
        diffMin.text = "-\(avg - min)"
        diffMax.text = "+\(max - avg)"
    }
    
    func initUI() {
        
        lineChartView.clear()
        
        min = 70
        max = 0
        avg = 0
        avgSum = 0
        avgCnt = 0
        
        maxValue.text = "0"
        minValue.text = "0"
        avgValue.text = "0"
        diffMin.text = "-0"
        diffMax.text = "+0"
        
    }
    
    func calcMinMax(_ value: Double) {
        let intValue = Int(value)
        
        if (intValue != 0){
            if (min > intValue){
                min = intValue
            }
            if (max < intValue){
                max = intValue
            }

            avgSum += intValue
            avgCnt += 1
            avg = avgSum/avgCnt
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
        
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(lineChartView)
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
        middleContents.addSubview(todayDisplay)
        todayDisplay.snp.makeConstraints { make in
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
