import Foundation
import UIKit

@available(iOS 13.0, *)
public class LoadingIndicator {
    private var activityIndicator: UIActivityIndicatorView?

    private init() {
        
    }

    public func show(in view: UIView) {
        DispatchQueue.main.async {
            if self.activityIndicator == nil {
                let indicator = UIActivityIndicatorView(style: .large)
                indicator.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(indicator)
                NSLayoutConstraint.activate([
                    indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
                ])
                self.activityIndicator = indicator
            }
            self.activityIndicator?.startAnimating()
        }
    }

    public func hide() {
        DispatchQueue.main.async {
            self.activityIndicator?.stopAnimating()
            self.activityIndicator?.removeFromSuperview()
            self.activityIndicator = nil
        }
    }
}
