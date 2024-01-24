import Foundation
import UIKit
import Then
import SnapKit
import PhoneNumberKit

public class AuthPhoneNumber: UIView, UITableViewDataSource, UITableViewDelegate{
    
    private let phoneNumberKit = PhoneNumberKit()
    private var countries: [String] {
        return phoneNumberKit.allCountries().filter { $0 != "001" }
    }
    
    private var phoneNumber = ""
    
    private lazy var toggleButton = UIButton().then {
        $0.setTitle("-", for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.titleLabel?.textAlignment = .center
        $0.setTitleColor(UIColor.darkGray, for: .normal)
        $0.addTarget(self, action: #selector(toggleButtonTapped), for: .touchUpInside)
    }
    
    private lazy var sendButton = UIButton().then {
        $0.setTitle("인증 요청", for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.titleLabel?.textAlignment = .center
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.backgroundColor = UIColor.MY_BLUE
//        $0.addTarget(self, action: #selector(toggleButtonTapped), for: .touchUpInside)
    }
    
    private lazy var tableView = UITableView().then {
        $0.dataSource = self
        $0.delegate = self
        $0.isHidden = true  // 초기에는 숨김
    }
    
    private let textField = UnderLineTextField().then {
        $0.textColor = .darkGray
        $0.keyboardType = .numberPad
        $0.tintColor = UIColor.MY_BLUE
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.placeholderString = "setupGuardianTxt".localized()
        $0.placeholderColor = UIColor.lightGray
        $0.tag = 0
    }
    
    @objc func toggleButtonTapped() {
        // 리스트 뷰의 표시 상태 토글
        tableView.isHidden = !tableView.isHidden
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
        updateToggleButtonTitle()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        setLayoutSubviews()
    }
    
    // MARK: tableView
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let countryCode = countries[indexPath.row]
        let currentLocale = Locale.current
        let countryName = currentLocale.localizedString(forRegionCode: countryCode) ?? countryCode
        let flag = emojiFlag(for: countryCode)
        cell.textLabel?.text = "\(flag) \(countryName)"
        return cell
    }
    
    // UITableViewDelegate
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCountry = countries[indexPath.row]
        let countryCode = phoneNumberKit.countryCode(for: selectedCountry) ?? 0
        let currentLocale = Locale.current
        let countryName = currentLocale.localizedString(forRegionCode: selectedCountry) ?? selectedCountry
        let flag = emojiFlag(for: selectedCountry)
        
        toggleButton.setTitle("\(flag) \(countryName)", for: .normal)
        tableView.isHidden = !tableView.isHidden
        
//        print("Selected Country: \(selectedCountry) - Code: \(countryCode)")
    }
    
    func emojiFlag(for countryCode: String) -> String {
        let base: UInt32 = 127397
        var s = ""
        for v in countryCode.uppercased().unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return s
    }
    
    private func updateToggleButtonTitle() {
        let currentLocale = Locale.current
        let countryCode = currentLocale.regionCode ?? "US"
        let countryName = currentLocale.localizedString(forRegionCode: countryCode) ?? countryCode
        let flag = emojiFlag(for: countryCode)
        toggleButton.setTitle("\(flag) \(countryName)", for: .normal)
    }
    
    // MARK: -
    @objc private func textFieldDidChange(_ textField: UITextField) {
        phoneNumber = textField.text ?? "Empty"
        print(phoneNumber)
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
    
    // MARK: -
    private func addViews(){
        
        self.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        let safeAreaView = UILabel().then { $0.backgroundColor = .white }
        self.addSubview(safeAreaView)
        safeAreaView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-50)
        }
        
        let authLabel = UILabel().then {
            $0.text = "본인인증"
            $0.textColor = .white
            $0.backgroundColor = UIColor.MY_BLUE
            $0.textAlignment = .center
            $0.layer.cornerRadius = 10
            $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]   // 왼쪽 위, 오른쪽 위 테두리 설정
            $0.clipsToBounds = true
        }
        self.addSubview(authLabel)
        authLabel.snp.makeConstraints { make in
            make.top.left.right.centerX.equalTo(safeAreaView)
            make.height.equalTo(40)
        }
        
        let helpText = UILabel().then {
            $0.text = "본인인증을 위한 핸드폰 번호를 입력해주세요"
            $0.textColor = UIColor.MY_BLUE
            $0.textAlignment = .center
        }
        self.addSubview(helpText)
        helpText.snp.makeConstraints { make in
            make.top.equalTo(authLabel.snp.bottom).offset(30)
            make.left.right.equalTo(safeAreaView)
        }
        
        let borderLabel = UILabel().then {
            $0.layer.borderColor = UIColor.MY_BLUE.cgColor
            $0.layer.cornerRadius = 10
            $0.layer.borderWidth = 2
            $0.layer.masksToBounds = true
            $0.backgroundColor = .clear
        }

        self.addSubview(borderLabel)
        borderLabel.snp.makeConstraints {
            $0.top.right.left.equalTo(safeAreaView)
            $0.bottom.equalToSuperview().offset(30)
        }
        
        self.addSubview(toggleButton)
        toggleButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-100)
            make.left.equalTo(safeAreaView).offset(10)
            make.width.equalTo(100)
        }
        
        self.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.left.equalTo(toggleButton.snp.right).offset(10)
            make.right.equalTo(safeAreaView).offset(-100)
            make.top.equalTo(toggleButton)
            make.bottom.equalTo(toggleButton).offset(1)
        }
        
        self.addSubview(sendButton)
        sendButton.snp.makeConstraints { make in
            make.top.bottom.equalTo(toggleButton)
            make.left.equalTo(textField.snp.right).offset(10)
            make.right.equalTo(safeAreaView).offset(-10)
        }
        
        self.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(toggleButton.snp.bottom).offset(10)  // toggleButton 아래에 위치
            make.left.right.equalToSuperview().inset(20)  // 양쪽 여백 설정
            make.bottom.equalToSuperview().inset(50)     // 하단 여백 설정
        }
    }
    
    private func setLayoutSubviews() {
        
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        sendButton.layer.cornerRadius = 10
        sendButton.layer.masksToBounds = true
        
        let underLine = UILabel().then {
            $0.backgroundColor = UIColor.MY_BLUE
        }
        
        self.addSubview(underLine)
        underLine.snp.makeConstraints { make in
            make.top.equalTo(toggleButton.snp.bottom).offset(1)
            make.left.equalTo(toggleButton).offset(3)
            make.right.equalTo(toggleButton)
            make.height.equalTo(2)
        }
    }
}
