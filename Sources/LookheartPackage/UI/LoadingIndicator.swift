import Foundation
import UIKit

@available(iOS 13.0, *)
public class LoadingIndicator {
    private var overlayView: UIView?
    private var activityIndicator: UIActivityIndicatorView?

    public init() {}

    public func show(in view: UIView) {
        DispatchQueue.main.async {
            if self.overlayView == nil {
                // overlay
                let overlay = UIView()
                overlay.backgroundColor = UIColor(white: 0, alpha: 0.5)
                overlay.isUserInteractionEnabled = true
                
                // indicator
                let indicator = UIActivityIndicatorView(style: .large)
                
                
                // addSubview
                view.addSubview(overlay)
                view.addSubview(indicator)
                
                
                // makeConstraints
                overlay.snp.makeConstraints { make in
                    make.top.bottom.left.right.equalTo(view)
                }
                
                indicator.snp.makeConstraints { make in
                    make.centerX.centerY.equalTo(view)
                }
                
                self.overlayView = overlay
                self.activityIndicator = indicator
            }
            
            self.overlayView?.isHidden = false
            self.activityIndicator?.startAnimating()
        }
    }

    public func hide() {
        DispatchQueue.main.async {
            self.activityIndicator?.stopAnimating()
            self.overlayView?.isHidden = true
        }
    }
}
