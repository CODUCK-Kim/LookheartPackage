import Foundation
import UIKit
import Then
import SnapKit
import PhoneNumberKit

public class AuthPhoneNumber: UIView, UITableViewDataSource, UITableViewDelegate{
    
    let phoneNumberKit = PhoneNumberKit()
    var countries: [String] {
        return phoneNumberKit.allCountries()
    }
            
    private lazy var toggleButton = UIButton().then {
        $0.setTitle("-", for: .normal)
        $0.setTitleColor(UIColor.black, for: .normal)
        $0.addTarget(self, action: #selector(toggleButtonTapped), for: .touchUpInside)
    }
    
    private lazy var tableView = UITableView().then {
        $0.dataSource = self
        $0.delegate = self
        $0.isHidden = true  // 초기에는 숨김
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
        print("Selected Country: \(selectedCountry) - Code: \(countryCode)")
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
        
        let borderLabel = UILabel().then {
            $0.layer.borderColor = UIColor.MY_BLUE.cgColor
            $0.layer.cornerRadius = 10
            $0.layer.borderWidth = 2
            $0.layer.masksToBounds = true
            $0.backgroundColor = .clear
            $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]   // 아래 모서리 테두리를 제거
        }

        self.addSubview(borderLabel)
        borderLabel.snp.makeConstraints {
            $0.top.bottom.right.left.equalTo(safeAreaView)
        }
        
        self.addSubview(toggleButton)
        toggleButton.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(50)
        }
        
        self.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(toggleButton.snp.bottom).offset(10)  // toggleButton 아래에 위치
            make.left.right.equalToSuperview().inset(20)  // 양쪽 여백 설정
            make.bottom.equalToSuperview().inset(50)     // 하단 여백 설정
        }
        
    }
}
