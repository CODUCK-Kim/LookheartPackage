import Foundation
import UIKit
import Then

public class CreateUI {
    
    public static let shared = CreateUI()
    
    public init() {}
        
    public func label(text: String, color: UIColor, font: UIFont) -> UILabel{
        let label = UILabel().then {
            $0.text = text
            $0.font = font
            $0.textColor = color
        }
        return label
    }
    
    public func imageView(image: UIImage, color: UIColor, contentMode: UIView.ContentMode) -> UIImageView {
        let imageView = UIImageView().then {
            $0.image = image
            $0.tintColor = color
            $0.contentMode = contentMode
        }
        return imageView
    }
    
    public func button(title: String, titleColor: UIColor, font: UIFont, backgroundColor: UIColor, tag: Int) -> UIButton {
        let button =  UIButton().then {
            $0.setTitle(title, for: .normal)
            $0.setTitleColor(titleColor, for: .normal)
            $0.titleLabel?.font = font
            $0.backgroundColor = backgroundColor
            $0.tag = tag
        }
        return button
    }
    
}
