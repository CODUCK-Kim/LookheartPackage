import Foundation
import UIKit

public class BasicAlert: UIViewController {
    
    private var titleLabel: UILabel?
    private var messageLabel: UILabel?
    
    private var alertTitle: String
    private var alertMessage: String
    
    // Init
    public init(title: String, message: String) {
        self.alertTitle = title
        self.alertMessage = message
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Button Event
    @objc func didTapActionButton() {
        dismiss(animated: true)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    public func updateText(title: String, message: String) {
        titleLabel?.text = title
        messageLabel?.text = message
    }
    
    private func addViews() {
        
        let screenWidth = UIScreen.main.bounds.width // Screen width
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        // create
        let backgroundView = UIView().then {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 20
            $0.layer.masksToBounds = true
        }
                     
        titleLabel = propCreateUI.label(text: alertTitle, color: .white, size: 18, weight: .heavy).then {
            $0.backgroundColor = UIColor.MY_RED
            $0.textAlignment = .center
        }
        
        
        titleLabel = propCreateUI.label(text: alertTitle, color: .black, size: 14, weight: .bold)
        
        messageLabel = propCreateUI.label(text: alertMessage, color: .black, size: 14, weight: .bold).then {
            $0.numberOfLines = 5
        }
        
        let backButton = UIButton().then {
            $0.setTitle("X", for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
            $0.backgroundColor = UIColor.MY_RED
            $0.tintColor = .white
            $0.layer.cornerRadius = 10
            $0.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
        }
                
        // addSubview
        view.addSubview(backgroundView)
        backgroundView.addSubview(titleLabel!)
        backgroundView.addSubview(messageLabel!)
        backgroundView.addSubview(backButton)
        
        
        // makeConstraints
        backgroundView.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(view)
            make.width.equalTo(screenWidth / 1.2)
            make.height.equalTo(200)
        }
        
        // Title
        titleLabel!.snp.makeConstraints { make in
            make.top.left.right.equalTo(backgroundView)
            make.height.equalTo(40)
        }
        
        // Message
        messageLabel!.snp.makeConstraints { make in
            make.top.equalTo(backgroundView.snp.bottom).offset(10)
            make.left.right.bottom.equalTo(backgroundView)
        }
        
        // Back Button
        backButton.snp.makeConstraints { make in
            make.top.bottom.equalTo(titleLabel!)
            make.left.equalTo(titleLabel!).offset(10)
        }
    }
}
