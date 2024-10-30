import Foundation
import UIKit
import DGCharts
import Combine

@available(iOS 13.0, *)
class LineChartVC : UIViewController {
    // ViewModel
    private let viewModel = DependencyInjection.shared.resolve(LineChartViewModel.self)
    private let lineChartController = DependencyInjection.shared.resolve(LineChartController.self)
    
    // Combine
    private var cancellables = Set<AnyCancellable>()
    
    /* Loading Bar */
    private var loadingIndicator = LoadingIndicator()
    
    // ----------------------------- Image ------------------- //
    private let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .light)
    private lazy var calendarImage =  UIImage( systemName: "calendar", withConfiguration: symbolConfiguration)?.withTintColor(.darkGray, renderingMode: .alwaysOriginal)
    // Image End

    // ----------------------------- TAG ------------------- //
    // 버튼 상수
    private let YESTERDAY_BUTTON_FLAG = 1
    private let TOMORROW_BUTTON_FLAG = 2
    
    private let TODAY_FLAG = 1
    private let TWO_DAYS_FLAG = 2
    private let THREE_DAYS_FLAG = 3
    
    private let PLUS_DATE = true, MINUS_DATE = false
    // TAG END
    
    
    // ----------------------------- CHART ------------------- //
    // 차트 관련 변수
    private var buttonList:[UIButton] = []
    // CHART END
    
    // MARK: - UI VAR
    private let safeAreaView = UIView()
    
    //    ----------------------------- Loding Bar -------------------    //
    private lazy var activityIndicator = UIActivityIndicatorView().then {
        // indicator 스타일 설정
        $0.style = UIActivityIndicatorView.Style.large
    }
    
    //    ----------------------------- FSCalendar -------------------    //
    private lazy var fsCalendar = CustomCalendar(frame: CGRect(x: 0, y: 0, width: 300, height: 300)).then {
        $0.isHidden = true
    }
    
    private lazy var lineChartView = LineChartView()
    
    //    ----------------------------- UILabel -------------------    //
    private let bottomLabel = UILabel().then {  $0.isUserInteractionEnabled = true  }
    
    private let topContents = UILabel().then {  $0.isUserInteractionEnabled = true  }
    
    private let middleContents = UILabel().then {   $0.isUserInteractionEnabled = true  }
    
    private let bottomContents = UILabel().then {   $0.isUserInteractionEnabled = true  }
    

    // MARK: - Top
    private lazy var todayButton = UIButton().then {
        $0.setTitle ("unit_today".localized(), for: .normal )
        
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
        $0.setTitle ("unit_twoDays".localized(), for: .normal )
        
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
        $0.setTitle ("unit_threeDays".localized(), for: .normal )
        
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
    
    private lazy var calendarButton = UIButton(type: .custom).then {
        $0.setImage(calendarImage, for: .normal)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 100)
        $0.addTarget(self, action: #selector(calendarButtonEvent(_:)), for: .touchUpInside)
    }
    
    
    // MARK: - Bottom
    private let leftContents = UILabel()
    
    private let rightContents = UILabel()
    
    private let centerContents = UILabel()
    
    private let maxLabel = UILabel().then {
        $0.text = "unit_max".localized()
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
        $0.text = "unit_min".localized()
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
        $0.text = "unit_bpm_avg".localized()
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }
    
    private let avgValue = UILabel().then {
        $0.text = "0"
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }
    
    private let valueLabel = UILabel().then {
        $0.text = "unit_bpm_upper".localized()
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }
    
    
    // MARK: - Button Evnet
    @objc func selectDayButton(_ sender: UIButton) {
        switch(sender.tag) {
        case TWO_DAYS_FLAG:
            viewModel?.updateDateType(.TWO_DAYS)
        case THREE_DAYS_FLAG:
            viewModel?.updateDateType(.THREE_DAYS)
        default:
            viewModel?.updateDateType(.TODAY)
        }
        
        setButtonColor(sender)
    }
    
    @objc func shiftDate(_ sender: UIButton) {
        let shiftFlag = sender.tag == TOMORROW_BUTTON_FLAG
        viewModel?.moveDate(nextDate: shiftFlag)
    }
    
    @objc func calendarButtonEvent(_ sender: UIButton) {
        fsCalendar.isHidden = !fsCalendar.isHidden
        lineChartView.isHidden = !lineChartView.isHidden
    }
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initVar()
        
        addViews()
        
        setupBindings()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        dissmissCalendar()
    }
    
    public func refreshView(lineChart: LineChartType) {
        updateChartUI(lineChart)
        
        setButtonColor(todayButton)
        
        viewModel?.refresh(type: lineChart)
        
        fsCalendar.isHidden = true
        lineChartView.isHidden = false
    }
    
    private func initVar() {
        setCalendarEvent()
        
        lineChartController?.setLineChart(lineChart: lineChartView)
        
        buttonList = [todayButton, twoDaysButton, threeDaysButton]
    }
    
    private func setCalendarEvent() {
        fsCalendar.didSelectDate = { [self] date in
            fsCalendar.isHidden = true
            lineChartView.isHidden = false
            
            viewModel?.moveDate(moveDate: date)
        }
    }
    
    private func setupBindings() {
        // init
        viewModel?.$initValue
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.initUI()
            }
            .store(in: &cancellables)
        
        // chart
        viewModel?.$chartModel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] chartModel in
                self?.updateValueUI(chartModel)
                self?.showChart(chartModel)
            }
            .store(in: &cancellables)
        
        
        // display date
        viewModel?.$displayDate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displyDate in
                self?.todayDisplay.text = displyDate
            }
            .store(in: &cancellables)
        
        
        // network response
        viewModel?.$networkResponse
            .receive(on: DispatchQueue.main)
            .sink { [weak self] response in
                self?.showErrorMessage(response)
            }
            .store(in: &cancellables)
        
        
        // loading
        viewModel?.$loading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] show in
                guard let view = self?.view else { return }
                
                if show {
                    self?.loadingIndicator.show(in: view)
                } else {
                    self?.loadingIndicator.hide()
                }
            }
            .store(in: &cancellables)
    }

    
    private func showChart(_ lineChartModel: LineChartModel?) {
        guard let lineChartModel else { return }
        guard let entries = lineChartModel.entries else {
            showErrorMessage(.noData)
            return
        }
                
        guard let chartDataSets = lineChartController?.getLineChartDataSet(
            entries: entries,
            chartType: lineChartModel.chartType,
            dateType: lineChartModel.dateType
        ) else {
            showErrorMessage(.noData)
            return
        }
        
        let lineChartData = LineChartData(dataSets: chartDataSets)
        
        lineChartController?.showChart(
            lineChart: lineChartView,
            chartData: lineChartData,
            timeTable: lineChartModel.timeTable,
            chartType: lineChartModel.chartType
        )
    }
    
    
    private func showErrorMessage(_ response: NetworkResponse?) {
        guard let response else { return }
        
        switch response {
        case .failer, .invalidResponse:
            showToastMessage("dialog_error_server_noData".localized())
        case .notConnected, .session:
            showToastMessage("dialog_error_internet".localized())
        case .noData:
            showToastMessage("dialog_error_noData".localized())
        default:
            print("other response: \(response)")
        }
    }
    
    
    
    
    // MARK: - UI
    private func updateChartUI(_ chartType: LineChartType) {
        switch chartType {
        case .BPM:
            avgLabel.text = "unit_bpm_avg".localized()
            valueLabel.text = "unit_bpm_upper".localized()
        case .HRV:
            avgLabel.text = "unit_hrv_avg".localized()
            valueLabel.text = "unit_hrv".localized()
        case .STRESS:
            break
        }
    }
    
    private func updateValueUI(_ lineChartModel: LineChartModel?) {
        guard let lineChartModel else { return }
        
        switch lineChartModel.chartType {
        case .BPM, .HRV:
            maxValue.text = String(lineChartModel.maxValue)
            minValue.text = String(lineChartModel.minValue)
            avgValue.text = String(lineChartModel.avgValue)
            
            diffMin.text = "-\(lineChartModel.avgValue - lineChartModel.minValue)"
            diffMax.text = "+\(lineChartModel.maxValue - lineChartModel.avgValue)"
        case .STRESS:
            break
        }
    }
    
    private func initUI() {
        lineChartView.clear()
        
        maxValue.text = "0"
        minValue.text = "0"
        avgValue.text = "0"
        diffMin.text = "-0"
        diffMax.text = "+0"
    }
    
    
    private func setButtonColor(_ sender: UIButton) {
        for button in buttonList {
            if button == sender {
                button.isSelected = true
            } else {
                button.isSelected = false
            }
        }
    }

    
    private func showToastMessage(_ message: String) {
        // chart location
        let chartViewCenterX = lineChartView.frame.size.width / 2
        let chartViewCenterY = lineChartView.frame.size.height / 2

        // size
        let containerWidth: CGFloat = lineChartView.frame.width - 60
        let containerHeight: CGFloat = 35

        // toast message location
        let toastPositionX = chartViewCenterX - containerWidth / 2
        let toastPositionY = chartViewCenterY - containerHeight / 2
        
        ToastHelper.shared.showChartToast(self.view, message, position: CGPoint(x: toastPositionX, y: toastPositionY))
    }
    
    private func dissmissCalendar() {
        if (!fsCalendar.isHidden) {
            fsCalendar.isHidden = true
            lineChartView.isHidden = false
        }
    }
    
    // MARK: -
    private func addViews() {
        let totalMultiplier = 4.0 // 1.0, 1.0, 2.0
        let singlePortion = 1.0 / totalMultiplier
        
        let screenWidth = UIScreen.main.bounds.width // Screen width
        let oneThirdWidth = screenWidth / 3.0
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally // 비율에 따라 공간 분배

        
        // addSubview
        view.addSubview(safeAreaView)
        view.addSubview(lineChartView)
        view.addSubview(activityIndicator)
        view.addSubview(stackView)
        
        stackView.addArrangedSubview(topContents)
        stackView.addArrangedSubview(middleContents)
        stackView.addArrangedSubview(bottomContents)
        
        
        // makeConstraints
        safeAreaView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        lineChartView.snp.makeConstraints { make in
            make.top.left.right.equalTo(safeAreaView)
            make.height.equalTo(safeAreaView).multipliedBy(5.5 / (5.5 + 4.5))
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(lineChartView)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(lineChartView.snp.bottom)
            make.left.right.bottom.equalTo(safeAreaView)
        }
        
        topContents.backgroundColor = .green
        middleContents.backgroundColor = .MY_BLUE
        bottomContents.backgroundColor = .MY_LIGHT_PINK
        
        topContents.snp.makeConstraints { make in
            make.height.equalTo(stackView).multipliedBy(0.3)
        }
        
        
        middleContents.snp.makeConstraints { make in
            make.height.equalTo(stackView).multipliedBy(0.3)
        }
        
        
        bottomContents.snp.makeConstraints { make in
            make.height.equalTo(stackView).multipliedBy(0.4)
        }
        
//        view.addSubview(bottomLabel)
//        bottomLabel.snp.makeConstraints { make in
//            make.top.equalTo(lineChartView.snp.bottom)
//            make.left.right.bottom.equalTo(safeAreaView)
//        }
        
//        bottomLabel.addSubview(topContents)
//        topContents.snp.makeConstraints { make in
//            make.top.equalTo(bottomLabel).offset(10)
//            make.left.equalTo(bottomLabel).offset(10)
//            make.right.equalTo(bottomLabel).offset(-10)
//            make.height.equalTo(bottomLabel).multipliedBy(singlePortion)
//        }
        
//        bottomLabel.addSubview(middleContents)
//        middleContents.snp.makeConstraints { make in
//            make.top.equalTo(topContents.snp.bottom)
//            make.left.right.equalTo(bottomLabel)
//            make.height.equalTo(bottomLabel).multipliedBy(singlePortion)
//        }
//        
//        bottomLabel.addSubview(bottomContents)
//        bottomContents.snp.makeConstraints { make in
//            make.top.equalTo(middleContents.snp.bottom)
//            make.left.right.bottom.equalTo(bottomLabel)
//        }
        
//        // --------------------- Top Contents --------------------- //
//        topContents.addSubview(twoDaysButton)
//        twoDaysButton.snp.makeConstraints { make in
//            make.top.centerX.equalTo(topContents)
//            make.bottom.equalTo(topContents).offset(-20)
//            make.width.equalTo(oneThirdWidth - 30)
//        }
//        
//        topContents.addSubview(todayButton)
//        todayButton.snp.makeConstraints { make in
//            make.top.equalTo(topContents)
//            make.left.equalTo(safeAreaView).offset(10)
//            make.bottom.equalTo(topContents).offset(-20)
//            make.width.equalTo(oneThirdWidth - 30)
//        }
//        
//        topContents.addSubview(threeDaysButton)
//        threeDaysButton.snp.makeConstraints { make in
//            make.top.equalTo(topContents)
//            make.right.equalTo(safeAreaView).offset(-10)
//            make.bottom.equalTo(topContents).offset(-20)
//            make.width.equalTo(oneThirdWidth - 30)
//        }
//        
//        // --------------------- middleContents --------------------- //
//        middleContents.addSubview(todayDisplay)
//        todayDisplay.snp.makeConstraints { make in
//            make.top.bottom.equalTo(middleContents)
//            make.centerX.equalTo(middleContents).offset(5)
//        }
//        
//        middleContents.addSubview(yesterdayButton)
//        yesterdayButton.snp.makeConstraints { make in
//            make.top.bottom.equalTo(middleContents)
//            make.left.equalTo(middleContents).offset(10)
//        }
//        
//        middleContents.addSubview(tomorrowButton)
//        tomorrowButton.snp.makeConstraints { make in
//            make.top.bottom.equalTo(middleContents)
//            make.right.equalTo(middleContents).offset(-10)
//        }
//        
//        middleContents.addSubview(calendarButton)
//        calendarButton.snp.makeConstraints { make in
//            make.centerY.equalTo(todayDisplay)
//            make.left.equalTo(todayDisplay.snp.left).offset(-30)
//        }
//        
//        // --------------------- bottomContents --------------------- //
//        bottomContents.addSubview(centerContents)
//        centerContents.snp.makeConstraints { make in
//            make.top.bottom.centerX.equalTo(bottomContents)
//            make.width.equalTo(oneThirdWidth)
//        }
//        
//        bottomContents.addSubview(leftContents)
//        leftContents.snp.makeConstraints { make in
//            make.top.bottom.left.equalTo(bottomContents)
//            make.width.equalTo(oneThirdWidth)
//        }
//        
//        bottomContents.addSubview(rightContents)
//        rightContents.snp.makeConstraints { make in
//            make.top.bottom.right.equalTo(bottomContents)
//            make.width.equalTo(oneThirdWidth)
//        }
//                
//        // --------------------- centerBpmContents --------------------- //
//        centerContents.addSubview(avgValue)
//        avgValue.snp.makeConstraints { make in
//            make.centerX.centerY.equalTo(centerContents)
//        }
//        
//        centerContents.addSubview(avgLabel)
//        avgLabel.snp.makeConstraints { make in
//            make.bottom.equalTo(avgValue.snp.top).offset(-10)
//            make.centerX.equalTo(centerContents)
//        }
//        
//        
//        centerContents.addSubview(valueLabel)
//        valueLabel.snp.makeConstraints { make in
//            make.top.equalTo(avgValue.snp.bottom).offset(10)
//            make.centerX.equalTo(centerContents)
//        }
//        
//        // --------------------- leftBpmContents --------------------- //
//        leftContents.addSubview(minValue)
//        minValue.snp.makeConstraints { make in
//            make.centerX.equalTo(leftContents)
//            make.centerY.equalTo(avgValue)
//        }
//        
//        leftContents.addSubview(minLabel)
//        minLabel.snp.makeConstraints { make in
//            make.centerX.equalTo(leftContents)
//            make.centerY.equalTo(avgLabel)
//        }
//        
//        
//        leftContents.addSubview(diffMin)
//        diffMin.snp.makeConstraints { make in
//            make.centerX.equalTo(leftContents)
//            make.centerY.equalTo(valueLabel)
//        }
//        
//        // --------------------- rightBpmContents --------------------- //
//        rightContents.addSubview(maxValue)
//        maxValue.snp.makeConstraints { make in
//            make.centerX.equalTo(rightContents)
//            make.centerY.equalTo(avgValue)
//        }
//        
//        rightContents.addSubview(maxLabel)
//        maxLabel.snp.makeConstraints { make in
//            make.centerX.equalTo(rightContents)
//            make.centerY.equalTo(avgLabel)
//        }
//    
//        
//        rightContents.addSubview(diffMax)
//        diffMax.snp.makeConstraints { make in
//            make.centerX.equalTo(rightContents)
//            make.centerY.equalTo(valueLabel)
//        }
//        
//        
//        view.addSubview(fsCalendar)
//        fsCalendar.snp.makeConstraints { make in
//            make.centerY.centerX.equalTo(lineChartView)
//            make.height.equalTo(300)
//            make.width.equalTo(300)
//        }
    }
}
