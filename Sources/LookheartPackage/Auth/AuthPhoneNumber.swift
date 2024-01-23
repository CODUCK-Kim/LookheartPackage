import Foundation
import UIKit
import Then
import SnapKit
import PhoneNumberKit

public class AuthPhoneNumber: UIViewController, UITableViewDataSource, UITableViewDelegate{

    public let safeView = UIView()
    
    let phoneNumberKit = PhoneNumberKit()
    var countries: [String] {
        return phoneNumberKit.allCountries()
    }
    
    private let toggleButton = UIButton().then {
        $0.setTitle("국가", for: .normal)
        $0.addTarget(AuthPhoneNumber.self, action: #selector(toggleButtonTapped), for: .touchUpInside)
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
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        addViews()
    }
    
    public func getView() -> UIView {
        return safeView
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
        cell.textLabel?.text = countryName
        return cell
    }
    
    // UITableViewDelegate
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCountry = countries[indexPath.row]
        let countryCode = phoneNumberKit.countryCode(for: selectedCountry) ?? 0
        print("Selected Country: \(selectedCountry) - Code: \(countryCode)")
    }
    
    // MARK: -
    private func addViews(){

        view.addSubview(safeView)
        safeView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        safeView.addSubview(toggleButton)
        toggleButton.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
        safeView.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
    }
    
}
