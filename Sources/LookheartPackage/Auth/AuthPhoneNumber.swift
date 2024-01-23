import Foundation
import UIKit
import PhoneNumberKit

class AuthPhoneNumber: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    let phoneNumberKit = PhoneNumberKit()
    var countries: [String] {
        return phoneNumberKit.allCountries()
    }

    @IBOutlet weak var countryPicker: UIPickerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        countryPicker.delegate = self
        countryPicker.dataSource = self
    }

    // UIPickerView DataSource & Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countries.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let country = countries[row]
        let code = phoneNumberKit.countryCode(for: country)
        return "\(country) (\(code))"
    }
}

