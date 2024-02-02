import UIKit

public class Alert {
    public func basicAlert(title: String, message: String, ok: String, viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let complite = UIAlertAction(title: ok, style: .default)
        alert.addAction(complite)
        viewController.present(alert, animated: true, completion: {})
    }
}
