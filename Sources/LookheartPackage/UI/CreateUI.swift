import Foundation
import UIKit
import Then

public class UIFactory {
    
    public static let shared = UIFactory()
    
    public init() {}
    
    public func image(
        named: String,
        size: CGFloat,
        color: UIColor,
        weight: UIImage.SymbolWeight = .regular,
        scale: UIImage.SymbolScale = .default
    ) -> UIImage? {
        let configuration = UIImage.SymbolConfiguration(pointSize: size, weight: weight, scale: scale)
        return UIImage(named: named, in: nil, with: configuration)?.withTintColor(color)
    }
    
    public func stackView(
        views: [UIView],
        axis: NSLayoutConstraint.Axis,
        distribution: UIStackView.Distribution,
        alignment: UIStackView.Alignment,
        spacing: CGFloat = 0
    ) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: views).then {
            $0.axis = .horizontal
            $0.distribution = .fillEqually
            $0.alignment = .fill
            $0.spacing = spacing
        }
        
        return stackView
    }
    
    public func progressView(
        backgroundColor: UIColor,
        tintColor: UIColor,
        progress: Float = 0,
        cornerRadius: CGFloat = 0,
        masksToBounds: Bool = true
    ) -> UIProgressView {
        let progressView = UIProgressView().then {
            $0.trackTintColor = backgroundColor
            $0.progressTintColor = tintColor
            $0.progress = progress
            $0.layer.cornerRadius = cornerRadius
            $0.layer.masksToBounds = masksToBounds
        }
        return progressView
    }
    
    public func textView(
        size: CGFloat,
        backgroundColor: UIColor,
        borderColor: CGColor? = nil,
        cornerRadius: CGFloat? = nil,
        borderWidth: CGFloat? = nil
    ) -> UITextView {
        let textView = UITextView().then {
            $0.font = UIFont.systemFont(ofSize: size)
            $0.backgroundColor = backgroundColor
            $0.layer.borderColor = borderColor
            $0.layer.cornerRadius = cornerRadius ?? 0
            $0.layer.borderWidth = borderWidth ?? 0
        }
        return textView
    }
    
    public func label(
        text: String? = nil,
        color: UIColor? = nil,
        font: UIFont
    ) -> UILabel {
        let label = UILabel().then {
            $0.text = text
            $0.font = font
            $0.textColor = color
        }
        return label
    }
    
    public func backgroundLabel(
        backgroundColor: UIColor,
        borderColor: CGColor,
        borderWidth: CGFloat,
        cornerRadius: CGFloat
    ) -> UILabel {
        let label = UILabel().then {
            $0.backgroundColor = backgroundColor
            $0.layer.borderColor = borderColor
            $0.layer.borderWidth = borderWidth
            $0.layer.cornerRadius = cornerRadius
            $0.layer.masksToBounds = true
        }
        return label
    }
    
    public func imageView(
        tintColor: UIColor,
        backgroundColor: UIColor,
        contentMode: UIView.ContentMode
    ) -> UIImageView {
        let imageView = UIImageView().then {
            $0.tintColor = tintColor
            $0.backgroundColor = backgroundColor
            $0.contentMode = contentMode
        }
        return imageView
    }
    
    public func button(
        title: String,
        titleColor: UIColor,
        size: CGFloat,
        weight: UIFont.Weight,
        backgroundColor: UIColor,
        tag: Int = 0
    ) -> UIButton {
        let button =  UIButton().then {
            $0.setTitle(title, for: .normal)
            $0.setTitleColor(titleColor, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: size, weight: weight)
            $0.backgroundColor = backgroundColor
            $0.tag = tag
        }
        return button
    }
    
}
