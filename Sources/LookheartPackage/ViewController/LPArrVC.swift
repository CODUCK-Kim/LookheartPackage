//import Foundation
//import Charts
//import UIKit
//
//@available(iOS 13.0, *)
//class LPArrVC : UIViewController {
//    
//    struct FileDataStruct {
//        var hour: Int
//        var minutes: Int
//        var second: Int
//        var arrNumber: Int
//    }
//    
//    private let SELECTED_COLOR = UIColor(red: 83/255, green: 136/255, blue: 247/255, alpha: 1.0)
//    private let DESELECTED_COLOR = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0)
//    private let BLACK_COLOR = UIColor.black
//    private let HEARTATTACK_COLOR = UIColor(red: 239/255, green: 80/255, blue: 123/255, alpha: 1.0)
//    
//    private let ARRDATA_FILENAME = "/arrEcgData_"
//    private let CSV_EXTENSION = ".csv"
//    
//    private let YESTERDAY_BUTTON_FLAG = 1
//    private let TOMORROW_BUTTON_FLAG = 2
//    
//    private let YESTERDAY = false
//    private let TOMORROW = true
//    
//    private let IDX_BUTTON = false
//    private let TITLE_BUTTON = true
//    
//    private let YEAR_FLAG = true
//    private let TIME_FLAG = false
//    
//    private var calendar = Calendar.current
//    private let dateFormatter = DateFormatter()
//    private let screenWidth = UIScreen.main.bounds.width
//    
//    private var currentYear:String = ""
//    private var currentMonth:String = ""
//    private var currentDay:String = ""
//    
//    private var targetDate:String = ""
//    private var targetYear:String = ""
//    private var targetMonth:String = ""
//    private var targetDay:String = ""
//    
//    private var tomorrowDate:String = ""
//    private var tomorrowYear:String = ""
//    private var tomorrowMonth:String = ""
//    private var tomorrowDay:String = ""
//    
//    private var email = ""
//    
//    private var arrDateArray:[String] = []
//    private var arrFilePath:[String] = []
//    private var arrDataEntries:[ChartDataEntry] = []
//    
//    private var idxButtonList: [UIButton] = []
//    private var titleButtonList: [UIButton] = []
//    private var arrNumber = 1
//    
//    private var emergencyIdxButtonList: [UIButton] = []
//    private var emergencyTitleButtonList: [UIButton] = []
//    private var emergencyList: [String: String] = [:]
//    private var emergencyNumber = 1
//
//    private var isArrViewLoaded: Bool = false
//    //    ----------------------------- File  -------------------    //
//    
//    // MARK: - UI
//    //    ----------------------------- Loding Bar -------------------    //
////    private var activityIndicator = UIActivityIndicatorView(style: .large)
//    private lazy var activityIndicator: UIActivityIndicatorView = {
//        let activityIndicator = UIActivityIndicatorView()
//        activityIndicator.style = UIActivityIndicatorView.Style.large // indicator의 스타일 설정, large와 medium이 있음
//        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
//        return activityIndicator
//    }()
//    
//    //    ----------------------------- Chart -------------------    //
//    private lazy var chartView: LineChartView =  {
//        let chartView = LineChartView()
//        chartView.xAxis.enabled = false
//        chartView.noDataText = ""
//        chartView.leftAxis.axisMaximum = 1024
//        chartView.leftAxis.axisMinimum = 0
//        chartView.rightAxis.enabled = false
//        chartView.legend.enabled = false
//        chartView.drawMarkers = false
//        chartView.dragEnabled = false
//        chartView.pinchZoomEnabled = false
//        chartView.doubleTapToZoomEnabled = false
//        chartView.highlightPerTapEnabled = false
//        chartView.chartDescription.enabled = true
//        chartView.chartDescription.font = .systemFont(ofSize: 20)
//        chartView.translatesAutoresizingMaskIntoConstraints = false
//        return chartView
//    }()
//    
//    let arrState: UILabel = {
//        let label = UILabel()
//
//        label.text = ""
//        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
//        label.textColor = .black
//        label.numberOfLines = 2
//        
//        label.isHidden = false
//        label.translatesAutoresizingMaskIntoConstraints = false
//        
//        return label
//    }()
//    
//    let arrStateLabel: UILabel = {
//        let label = UILabel()
//
//        label.text = "arrType".localized()
//        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
//        label.textColor = .darkGray
//        label.numberOfLines = 2
//        
//        label.isHidden = false
//        label.translatesAutoresizingMaskIntoConstraints = false
//        
//        return label
//    }()
//    
//    let bodyState: UILabel = {
//        let label = UILabel()
//
//        label.text = ""
//        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
//        label.textColor = .black
//        label.isHidden = false
//        label.translatesAutoresizingMaskIntoConstraints = false
//        
//        return label
//    }()
//    
//    let bodyStateLabel: UILabel = {
//        let label = UILabel()
//
//        label.text = "arrState".localized()
//        label.font = UIFont.systemFont(ofSize: 14, weight: .medium) // 크기, 굵음 정도 설정
//        label.textColor = .darkGray
//        label.isHidden = false
//        label.translatesAutoresizingMaskIntoConstraints = false
//        
//        return label
//    }()
//    
//    
//    //    ----------------------------- ARR List Contents -------------------    //
//    
//    private let listBackground: UILabel = {
//        let label = UILabel()
//        label.isUserInteractionEnabled = true
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private lazy var todayDispalay = UILabel().then {
//        $0.text = "\(currentYear)-\(currentMonth)-\(currentDay)"
//        $0.textColor = .black
//        $0.textAlignment = .center
//        $0.baselineAdjustment = .alignCenters
//        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
//        $0.translatesAutoresizingMaskIntoConstraints = false
//    }
//    
//    private lazy var yesterdayButton = UIButton().then {
//        $0.setImage(leftArrow, for: UIControl.State.normal)
//        $0.tag = YESTERDAY_BUTTON_FLAG
//        $0.addTarget(self, action: #selector(shiftDate(_:)), for: .touchUpInside)
//        $0.translatesAutoresizingMaskIntoConstraints = false
//    }
//    private lazy var tomorrowButton = UIButton().then {
//        $0.setImage(rightArrow, for: UIControl.State.normal)
//        $0.tag = TOMORROW_BUTTON_FLAG
//        $0.addTarget(self, action: #selector(shiftDate(_:)), for: .touchUpInside)
//        $0.translatesAutoresizingMaskIntoConstraints = false
//    }
//    
//    private let scrollView: UIScrollView = {
//        let scrollView = UIScrollView()
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        return scrollView
//    }()
//    
//    private var arrList: UIStackView = {
//        let stackView = UIStackView()
//        stackView.axis = .vertical
//        stackView.spacing = 10
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        return stackView
//    }()
//    
//    // MARK: - viewDidLoad
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        initVar()
//        addViews()
//        arrTable()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        if isArrViewLoaded {
//            viewDidLoad()
//        }
//        isArrViewLoaded = true
//    }
//    
//    func initVar() {
//        
//        let currentDate = MyDateTime.shared.getSplitDateTime(.DATE)
//        
//        email = UserProfileManager.shared.getEmail()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        
//        currentYear = currentDate[0]
//        currentMonth = currentDate[1]
//        currentDay = currentDate[2]
//        
//        targetDate = MyDateTime.shared.getCurrentDateTime(.DATE)
//        targetYear = currentYear
//        targetMonth = currentMonth
//        targetDay = currentDay
//        
//        setTomorrow(targetDate)
//    }
//    
//    //MARK: - setTable
//    func arrTable() {
//        todayDispalay.text = changeTimeFormat(targetDate, YEAR_FLAG)
//        initArray()
//        getArrList(email, targetDate, tomorrowDate)
//        
//    }
//    
//    
//    
//    func getArrList(_ email: String, _ startDate: String, _ endDate: String) {
//        activityIndicator.startAnimating()
//        NetworkManager.shared.getArrListToServer(id: email, startDate: startDate, endDate: endDate){ [weak self] result in
//            DispatchQueue.main.async {
//                self?.activityIndicator.stopAnimating()
//                guard let self = self else { return }
//                
//                switch(result){
//                case .success(let arrDateList):
//                    for arrDate in arrDateList {
//                        if arrDate.address == nil || arrDate.address == "" { // ARR
//                            self.arrDateArray.append(arrDate.writetime)
//                        } else {    // HEART ATTACK
//                            self.arrDateArray.append(arrDate.writetime)
//                            self.emergencyList[arrDate.writetime] = arrDate.address
//                        }
//                    }
//                    self.setArrList()
//                case .failure(let error):
//                    ToastHelper.shared.showToast(self.view, "againLater".localized(), withDuration: 1.0, delay: 1.0, bottomPosition: false)
//                    print("getArrList error : \(error)")
//                }
//            }
//        }
//    }
//    
//    // MARK: - selectArrData
//    func selectArrData(_ startDate: String) {
//        activityIndicator.startAnimating()
//        NetworkManager.shared.selectArrDataToServer(id: email, startDate: startDate ) { [weak self] result in
//            DispatchQueue.main.async {
//                self?.activityIndicator.stopAnimating()
//                guard let self = self else { return }
//                
//                switch(result) {
//                case .success(let arrData):
//                    self.arrChart(arrData)
//                case .failure(let error):
//                    ToastHelper.shared.showToast(self.view, "againLater".localized(), withDuration: 1.0, delay: 1.0, bottomPosition: false)
//                    print("select Arr Data error : \(error)")
//                }
//            }
//        }
//    }
//    
//    func setArrList() {
//        for arrDateArray in arrDateArray {
//            var arrIdxButton = UIButton()
//            var arrTitleButton = UIButton()
//            let background = UILabel()
//            background.isUserInteractionEnabled = true
//            
//            arrList.addArrangedSubview(background)
//            
//            if emergencyList[arrDateArray] != nil {
//                // Emergency
//                arrIdxButton = setEmergencyIdxButton("E")
//                arrTitleButton = setEmergencyTitleButton(arrDateArray)
//                emergencyIdxButtonList.append(arrIdxButton)
//                emergencyTitleButtonList.append(arrTitleButton)
//                emergencyNumber += 1
//            } else {
//                // ARR
//                arrIdxButton = setIdxButton(arrNumber)
//                arrTitleButton = setTitleButton(arrDateArray)
//                idxButtonList.append(arrIdxButton)
//                titleButtonList.append(arrTitleButton)
//                arrNumber += 1
//            }
//            
//            setButtonConstraint(background, arrIdxButton, arrTitleButton)
//                    
//        }
//        
//        if arrNumber >= 10 {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                self.scrollToBottom()
//            }
//        }
//    }
//    
//    // MARK: - Chart
//    private func arrChart(_ arrData: ArrData) {
//        if arrData.data.count < 400 {   return  }
//        
//        let ecgDataConversion = EcgDataConversion()
//        var arrDataEntry: ChartDataEntry
//        arrDataEntries = []
//        
//        stateIsHidden(isHidden: false)
//        setState(bodyType: arrData.bodyStatus,
//                 arrType: arrData.type)
//        
////        setPreEcgData(ecgDataConversion, arrData)   // 초기 ECG 데이터 설정
//        
//        for i in 0...arrData.data.count - 1{
//            if ecgFlag {
//                arrDataEntry = ChartDataEntry(x: Double(i), y: Double(arrData.data[i]))
//            } else {
//                let conversionData = ecgDataConversion.changeEcgData(arrData.data[i])
//                arrDataEntry = ChartDataEntry(x: Double(i), y: Double(conversionData))
//            }
//        
//            arrDataEntries.append(arrDataEntry)
//        }
//        
//        let arrChartDataSet = LineChartDataSet(entries: arrDataEntries, label: "Peak")
//        arrChartDataSet.drawCirclesEnabled = false
//        arrChartDataSet.setColor(NSUIColor.blue)
//        arrChartDataSet.mode = .linear
//        arrChartDataSet.drawValuesEnabled = false
//        
//        chartView.data = LineChartData(dataSet: arrChartDataSet)
//        chartView.data?.notifyDataChanged()
//        chartView.notifyDataSetChanged()
//        chartView.moveViewToX(0)
//    }
//    
//    private func setPreEcgData(_ ecgDataConversion: EcgDataConversion, _ arrData: ArrData) {
//        let preEcgData = findPreEcgData(arrData.preEcgData, arrData.data)
//        for i in 0...preEcgData.count - 1 {
//            _ = ecgDataConversion.setPeakData(Int(preEcgData[i]))
//        }
//    }
//    
//    private func findPreEcgData(_ ecgData: [Double], _ arrData: [Double]) -> [Double] {
//        let checkArrData = arrData.prefix(14)
//        
//        var startIndex = 0
//        var arrIndex = 0
//        
//        for index in 0...ecgData.count - 1 {
//            if ecgData[index] == checkArrData[arrIndex] {    arrIndex += 1   }
//            else {  arrIndex = 0    }
//            
//            if arrIndex == 14 {
//                startIndex = index - (arrIndex - 1)
//                break
//            }
//        }
//
//        return Array(ecgData.suffix(from: startIndex))
//    }
//    
//    private func emergencyChart(_ arrDate: String) {
//        arrDataEntries = []
//        
//        stateIsHidden(isHidden: false)
//        setEmergencyText(state: "profile3_emergency".localized(), location: String(emergencyList[arrDate] ?? "empty"))
//        
//        for i in 0...499 {
//            let arrDataEntry = ChartDataEntry(x: Double(i), y: 0.0)
//            arrDataEntries.append(arrDataEntry)
//        }
//        
//        let arrChartDataSet = LineChartDataSet(entries: arrDataEntries, label: "Peak")
//        arrChartDataSet.drawCirclesEnabled = false
//        arrChartDataSet.setColor(NSUIColor(red: 239/255, green: 80/255, blue: 123/255, alpha: 1.0))
//        arrChartDataSet.mode = .linear
//        arrChartDataSet.drawValuesEnabled = false
//        
//        chartView.data = LineChartData(dataSet: arrChartDataSet)
//        chartView.data?.notifyDataChanged()
//        chartView.notifyDataSetChanged()
//        chartView.moveViewToX(0)
//    }
//    
//    private func setState(bodyType: String, arrType: String){
//        arrStateLabel.text = "arrType".localized()
//        bodyState.text = getBodyType(bodyType)
//        arrState.text = getArrType(arrType)
//    }
//    
//    private func getArrType(_ arrType: String ) -> String {
//        switch (arrType){
//        case "fast":
//            return "typeFastArr".localized()
//        case "slow":
//            return "typeSlowArr".localized()
//        case "irregular":
//            return "typeHeavyArr".localized()
//        default:    // "arr"
//            return "typeArr".localized()
//        }
//    }
//    
//    private func getBodyType(_ bodyType: String ) -> String {
//        switch (bodyType){
//        case "E":
//            return "type_Exercise".localized()
//        case "S":
//            return "type_Sleep".localized()
//        default:    // "R"
//            return "type_Rest".localized()
//        }
//    }
//    
//    // MARK: -
//    @objc func shiftDate(_ sender: UIButton) {
//        
//        switch(sender.tag) {
//        case YESTERDAY_BUTTON_FLAG:
//            dateCalculate(targetDate, 1, YESTERDAY)
//        default:    // TOMORROW_BUTTON_FLAG
//            dateCalculate(targetDate, 1, TOMORROW)
//        }
//        arrTable()
//    }
//    
//    func fcmEvent() {
//        var arrIdxButton = UIButton()
//        var arrTitleButton = UIButton()
//        let background = UILabel()
//        background.isUserInteractionEnabled = true
//        arrList.addArrangedSubview(background)
//        
//        arrIdxButton = setEmergencyIdxButton("T")
//        arrTitleButton = setTitleButton("2000-00-00 00:00:00")
//        idxButtonList.append(arrIdxButton)
//        titleButtonList.append(arrTitleButton)
//        arrNumber += 1
//        
//        setButtonConstraint(background, arrIdxButton, arrTitleButton)
//    }
//    
//    func dateCalculate(_ date: String, _ day: Int, _ shouldAdd: Bool) {
//        guard let inputDate = dateFormatter.date(from: date) else { return }
//
//        let dayValue = shouldAdd ? day : -day
//
//        if let arrTargetDate = calendar.date(byAdding: .day, value: dayValue, to: inputDate) {
//            
//            let components = calendar.dateComponents([.year, .month, .day], from: arrTargetDate)
//            
//            if let year = components.year, let month = components.month, let day = components.day {
//                targetYear = "\(year)"
//                targetMonth = "\(month)"
//                targetDay = "\(day)"
//                
//                targetDate = "\(targetYear)-\(targetMonth)-\(targetDay)"
//                setTomorrow(targetDate)
//            }
//        }
//    }
//    
//    func setTomorrow(_ date: String) {
//        guard let inputDate = dateFormatter.date(from: date) else { return }
//        
//        if let arrTargetDate = calendar.date(byAdding: .day, value: 1, to: inputDate) {
//            
//            let components = calendar.dateComponents([.year, .month, .day], from: arrTargetDate)
//            
//            if let year = components.year, let month = components.month, let day = components.day {
//                tomorrowYear = "\(year)"
//                tomorrowMonth = "\(month)"
//                tomorrowDay = "\(day)"
//                
//                tomorrowDate = "\(tomorrowYear)-\(tomorrowMonth)-\(tomorrowDay)"
//            }
//        }
//    }
//    
//    // MARK: - Arr Button Event
//    func setIdxButton(_ idx: Int) -> UIButton {
//        let arrIdxButton = UIButton()
//        
//        arrIdxButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
//        arrIdxButton.titleLabel?.textAlignment = .center
//        
//        arrIdxButton.setTitle("\(idx)", for: .normal)
//        arrIdxButton.setTitleColor(.white, for: .normal)
//        
//        arrIdxButton.backgroundColor = .black
//        
//        arrIdxButton.layer.cornerRadius = 10
//        arrIdxButton.layer.borderWidth = 3
//        arrIdxButton.clipsToBounds = true
//        arrIdxButton.tag = arrNumber
//        
//        arrIdxButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
//        
//        return arrIdxButton
//    }
//    
//    func setTitleButton(_ title: String) -> UIButton {
//        let arrTitleButton = UIButton()
//        
//        arrTitleButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
//        arrTitleButton.titleLabel?.textAlignment = .center
//        
//        arrTitleButton.setTitle("\(changeTimeFormat(title, TIME_FLAG))", for: .normal)
//        arrTitleButton.setTitleColor(.black, for: .normal)
//        
//        arrTitleButton.setBackgroundColor(.white, for: .normal)
//        
//        arrTitleButton.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0).cgColor
//        arrTitleButton.layer.cornerRadius = 10
//        arrTitleButton.layer.borderWidth = 3
//        arrTitleButton.tag = arrNumber
//        
//        arrTitleButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
//        return arrTitleButton
//    }
//    
//    @objc func buttonTapped(_ sender: UIButton) {
//        selectArrData(arrDateArray[sender.tag - 1])
//        updateButtonColor(sender.tag - 1)
//    }
//    
//    func updateButtonColor(_ tag: Int) {
//        // IDX
//        for button in idxButtonList {
//            if idxButtonList[tag] == button {
//                button.backgroundColor = SELECTED_COLOR
//                button.layer.borderColor = SELECTED_COLOR.cgColor
//            } else {
//                button.backgroundColor = BLACK_COLOR
//                button.layer.borderColor = BLACK_COLOR.cgColor
//            }
//        }
//        // TITLE
//        for button in titleButtonList {
//            if titleButtonList[tag] == button {
//                button.layer.borderColor = SELECTED_COLOR.cgColor
//            } else {
//                button.layer.borderColor = DESELECTED_COLOR.cgColor
//            }
//        }
//        allDeSelected(idxList: &emergencyIdxButtonList, titleList: &emergencyTitleButtonList)
//    }
//    
//    // MARK: - Emergency Button Event
//    func setEmergencyIdxButton(_ number: String) -> UIButton {
//        let arrIdxButton = UIButton()
//        
//        arrIdxButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
//        arrIdxButton.titleLabel?.textAlignment = .center
//        
//        arrIdxButton.setTitle("\(number)", for: .normal)
//        arrIdxButton.setTitleColor(.white, for: .normal)
//        
//        arrIdxButton.backgroundColor = .black
//        
//        arrIdxButton.layer.cornerRadius = 10
//        arrIdxButton.layer.borderWidth = 3
//        arrIdxButton.clipsToBounds = true
//        arrIdxButton.tag = emergencyNumber
//        
//        arrIdxButton.addTarget(self, action: #selector(emergencyButtonTapped(_:)), for: .touchUpInside)
//        
//        return arrIdxButton
//    }
//    func setEmergencyTitleButton(_ title: String) -> UIButton {
//        let arrTitleButton = UIButton()
//        
//        arrTitleButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
//        arrTitleButton.titleLabel?.textAlignment = .center
//        
//        arrTitleButton.setTitle("\(changeTimeFormat(title, TIME_FLAG))", for: .normal)
//        arrTitleButton.setTitleColor(.black, for: .normal)
//        
//        arrTitleButton.setBackgroundColor(.white, for: .normal)
//        
//        arrTitleButton.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0).cgColor
//        arrTitleButton.layer.cornerRadius = 10
//        arrTitleButton.layer.borderWidth = 3
//        arrTitleButton.tag = emergencyNumber
//        
//        arrTitleButton.addTarget(self, action: #selector(emergencyButtonTapped(_:)), for: .touchUpInside)
//        return arrTitleButton
//    }
//    
//    @objc func emergencyButtonTapped(_ sender: UIButton) {
//        emergencyChart(sender.titleLabel?.text ?? "")
//        updateEmergencyButtonColor(sender.tag - 1)
//    }
//    
//    func updateEmergencyButtonColor(_ tag: Int) {
//        // IDX
//        for button in emergencyIdxButtonList {
//            if emergencyIdxButtonList[tag] == button {
//                button.backgroundColor = HEARTATTACK_COLOR
//                button.layer.borderColor = HEARTATTACK_COLOR.cgColor
//            } else {
//                button.backgroundColor = BLACK_COLOR
//                button.layer.borderColor = BLACK_COLOR.cgColor
//            }
//        }
//        // TITLE
//        for button in emergencyTitleButtonList {
//            if emergencyTitleButtonList[tag] == button {
//                button.layer.borderColor = HEARTATTACK_COLOR.cgColor
//            } else {
//                button.layer.borderColor = DESELECTED_COLOR.cgColor
//            }
//        }
//        
//        allDeSelected(idxList: &idxButtonList, titleList: &titleButtonList)
//    }
//    
//    func allDeSelected(idxList: inout [UIButton], titleList: inout [UIButton]) {
//        for button in idxList {
//            button.backgroundColor = BLACK_COLOR
//            button.layer.borderColor = BLACK_COLOR.cgColor
//        }
//        for button in titleList {
//            button.layer.borderColor = DESELECTED_COLOR.cgColor
//        }
//    }
//    
//    // MARK: -
//    func setStackView() -> UIStackView {
//        let rowStack = UIStackView()
//        rowStack.axis = .horizontal
//        rowStack.distribution = .fill
//        rowStack.alignment = .fill
//        rowStack.spacing = 8
//        rowStack.translatesAutoresizingMaskIntoConstraints = false
//        return rowStack
//    }
//    
//    func setButtonConstraint(_ background: UILabel, _ arrIdxButton: UIButton, _ arrTitleButton: UIButton) {
//        background.translatesAutoresizingMaskIntoConstraints = false
//        arrIdxButton.translatesAutoresizingMaskIntoConstraints = false
//        arrTitleButton.translatesAutoresizingMaskIntoConstraints = false
//
//        background.addSubview(arrIdxButton)
//        background.addSubview(arrTitleButton)
//        
//        NSLayoutConstraint.activate([
//            background.leadingAnchor.constraint(equalTo: arrList.leadingAnchor),
//            background.trailingAnchor.constraint(equalTo: arrList.trailingAnchor),
//            background.heightAnchor.constraint(equalToConstant: 50),
//            
//            arrIdxButton.topAnchor.constraint(equalTo: background.topAnchor),
//            arrIdxButton.leadingAnchor.constraint(equalTo: background.leadingAnchor),
//            arrIdxButton.bottomAnchor.constraint(equalTo: background.bottomAnchor),
//            arrIdxButton.widthAnchor.constraint(equalToConstant: screenWidth / 7.0),
//            
//            arrTitleButton.topAnchor.constraint(equalTo: background.topAnchor),
//            arrTitleButton.leadingAnchor.constraint(equalTo: arrIdxButton.trailingAnchor, constant: 10),
//            arrTitleButton.trailingAnchor.constraint(equalTo: background.trailingAnchor, constant: -10),
//            arrTitleButton.bottomAnchor.constraint(equalTo: background.bottomAnchor),
//            
//        ])
//    }
//    
//    func changeTimeFormat(_ dateString: String, _ isYearCheck: Bool) -> String {
//        if isYearCheck {
//            var dateComponents = dateString.components(separatedBy: "-")
//            dateComponents[1] = String(format: "%02d", Int(dateComponents[1])!)
//            dateComponents[2] = String(format: "%02d", Int(dateComponents[2])!)
//            
//            return dateComponents.joined(separator: "-")
//        } else {
//            let splitDate = dateString.split(separator: " ")    // 2023-11-09 9:16:18
//            var dateComponents = splitDate[1].components(separatedBy: ":")
//            let date = changeTimeFormat(String(splitDate[0]), YEAR_FLAG)
//            
//            dateComponents[0] = String(format: "%02d", Int(dateComponents[0])!)
//            dateComponents[1] = String(format: "%02d", Int(dateComponents[1])!)
//            dateComponents[2] = String(format: "%02d", Int(dateComponents[2])!)
//            
//            return "\(date) \(dateComponents.joined(separator: ":"))"
//        }
//    }
//    
//    func reconstructedPath(_ path: URL) -> String? {
//        
//        if let documentsIndex = path.pathComponents.firstIndex(of: "arrECGData") {
//            let desiredPathComponents = path.pathComponents[(documentsIndex + 1)...]
//            return desiredPathComponents.joined(separator: "/")
//        }
//        return nil
//    }
//    
//    func resetArrList() {
//        for  subview in self.arrList.subviews
//        {
//            subview.removeFromSuperview()
//        }
//    }
//    
//    func stateIsHidden(isHidden: Bool) {
//        bodyState.isHidden = isHidden
//        bodyStateLabel.isHidden = isHidden
//        arrState.isHidden = isHidden
//        arrStateLabel.isHidden = isHidden
//    }
//    
//    func setEmergencyText(state: String, location: String) {
//        arrState.text = "\(location)"
//        arrStateLabel.text = "emergencyLocation".localized()
//        bodyState.isHidden = true
//        bodyStateLabel.isHidden = true
//    }
//    
//    func scrollToBottom() {
//        scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.height), animated: true)
//    }
//    
//    func initArray() {
//        
//        resetArrList()
//        stateIsHidden(isHidden: true)
//        
//        chartView.clear()
//        
//        arrDateArray = []
//        arrFilePath = []
//        arrDataEntries = []
//        
//        idxButtonList = []
//        titleButtonList = []
//        arrNumber = 1
//        
//        emergencyList = [:]
//        emergencyIdxButtonList = []
//        emergencyTitleButtonList = []
//        emergencyNumber = 1
//    }
//    
//    private func autoresizing(view: UIView) {
//        view.translatesAutoresizingMaskIntoConstraints = false
//    }
//    
//    // MARK: - addViews
//    private func addViews() {
//        
//        view.addSubview(chartView)
//        view.addSubview(activityIndicator)
//        view.addSubview(listBackground)
//        
//        view.addSubview(arrState)
//        view.addSubview(arrStateLabel)
//        view.addSubview(bodyState)
//        view.addSubview(bodyStateLabel)
//        
//        listBackground.addSubview(todayDispalay)
//        listBackground.addSubview(yesterdayButton)
//        listBackground.addSubview(tomorrowButton)
//        listBackground.addSubview(scrollView)
//        
//        scrollView.addSubview(arrList)
//        
//        setConstraints()
//    }
//    
//    // MARK: - Constraints
//    private func setConstraints(){
//        
//        NSLayoutConstraint.activate([
//            // chart
//            chartView.topAnchor.constraint(equalTo: safeAreaView.topAnchor),
//            chartView.leadingAnchor.constraint(equalTo: safeAreaView.leadingAnchor),
//            chartView.trailingAnchor.constraint(equalTo: safeAreaView.trailingAnchor),
//            chartView.heightAnchor.constraint(equalTo: safeAreaView.heightAnchor, multiplier: 4.5 / (4.5 + 5.5)),
//            
//            activityIndicator.centerXAnchor.constraint(equalTo: chartView.centerXAnchor),
//            activityIndicator.centerYAnchor.constraint(equalTo: chartView.centerYAnchor),
//            // state
//            arrState.trailingAnchor.constraint(equalTo: safeAreaView.trailingAnchor, constant: -20),
//            arrState.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: 10),
//            
//            arrStateLabel.trailingAnchor.constraint(equalTo: arrState.leadingAnchor, constant: -10),
//            arrStateLabel.topAnchor.constraint(equalTo: arrState.topAnchor),
//            
//            bodyState.trailingAnchor.constraint(equalTo: arrStateLabel.leadingAnchor, constant: -10),
//            bodyState.topAnchor.constraint(equalTo: arrStateLabel.topAnchor),
//            
//            bodyStateLabel.trailingAnchor.constraint(equalTo: bodyState.leadingAnchor, constant: -10),
//            bodyStateLabel.topAnchor.constraint(equalTo: bodyState.topAnchor),
//                        
//            // background
//            listBackground.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: 50),
//            listBackground.leadingAnchor.constraint(equalTo: safeAreaView.leadingAnchor),
//            listBackground.trailingAnchor.constraint(equalTo: safeAreaView.trailingAnchor),
//            listBackground.bottomAnchor.constraint(equalTo: safeAreaView.bottomAnchor),
//            
//            // contents
//            todayDispalay.topAnchor.constraint(equalTo: listBackground.topAnchor),
//            todayDispalay.centerXAnchor.constraint(equalTo: listBackground.centerXAnchor),
//            
//            yesterdayButton.leadingAnchor.constraint(equalTo: listBackground.leadingAnchor, constant: 10),
//            yesterdayButton.centerYAnchor.constraint(equalTo: todayDispalay.centerYAnchor),
//            
//            tomorrowButton.trailingAnchor.constraint(equalTo: listBackground.trailingAnchor, constant: -10),
//            tomorrowButton.centerYAnchor.constraint(equalTo: todayDispalay.centerYAnchor),
//            
//            scrollView.topAnchor.constraint(equalTo: todayDispalay.bottomAnchor, constant: 20),
//            scrollView.leadingAnchor.constraint(equalTo: listBackground.leadingAnchor, constant: 10),
//            scrollView.trailingAnchor.constraint(equalTo: listBackground.trailingAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: listBackground.bottomAnchor, constant: -10),
//            
//            arrList.topAnchor.constraint(equalTo: scrollView.topAnchor),
//            arrList.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
//            arrList.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
//        ])
//    }
//    
//}
