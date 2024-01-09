// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit

open class SummaryView {

    private let BPM_BUTTON_TAG = 1
    private let ARR_BUTTON_TAG = 2
    private let HRV_BUTTON_TAG = 3
    private let CAL_BUTTON_TAG = 4
    private let STEP_BUTTON_TAG = 5
    
//    private let bpmView = SummaryBpm()
//    private let arrView = SummaryArr()
//    private let hrvView = SummaryHrv()
//    private let calView = SummaryCal()
//    private let stepView = SummaryStep()
    
    var arrChild: [UIViewController] = []
    
    private lazy var buttons: [UIButton] = {
        return [bpmButton, arrButton, hrvButton, calorieButton, stepButton]
    }()
    
    private lazy var images: [UIImageView] = {
        return [bpmImage, arrImage, hrvImage, calorieImage, stepImage]
    }()
    
//    private lazy var childs: [UIViewController] = {
//        return [bpmView, arrView, hrvView, calView, stepView]
//    }()
    
    // MARK: - top Button
    // ------------------------ IMG ------------------------
    private lazy var bpmImage: UIImageView = {
        var imageView = UIImageView()
        let image = UIImage(named: "summary_bpm")?.withRenderingMode(.alwaysTemplate)
        imageView = UIImageView(image: image)
        imageView.tintColor = UIColor.white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private lazy var arrImage: UIImageView = {
        var imageView = UIImageView()
        let image = UIImage(named: "summary_arr")?.withRenderingMode(.alwaysTemplate)
        imageView = UIImageView(image: image)
        imageView.tintColor = UIColor.lightGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private lazy var hrvImage: UIImageView = {
        var imageView = UIImageView()
        let image = UIImage(named: "summary_hrv")?.withRenderingMode(.alwaysTemplate)
        imageView = UIImageView(image: image)
        imageView.tintColor = UIColor.lightGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private lazy var calorieImage: UIImageView = {
        var imageView = UIImageView()
        let image = UIImage(named: "summary_cal")?.withRenderingMode(.alwaysTemplate)
        imageView = UIImageView(image: image)
        imageView.tintColor = UIColor.lightGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private lazy var stepImage: UIImageView = {
        var imageView = UIImageView()
        let image = UIImage(named: "summary_step")?.withRenderingMode(.alwaysTemplate)
        imageView = UIImageView(image: image)
        imageView.tintColor = UIColor.lightGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // ------------------------ BUTTON ------------------------
    private lazy var bpmButton: UIButton = {
        let button = UIButton()
        button.setTitle("summaryBpm".localized(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        button.titleLabel?.contentMode = .center
        button.backgroundColor = UIColor(red: 45/255, green: 63/255, blue: 100/255, alpha: 1.0)
        button.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0).cgColor
        button.layer.borderWidth = 0
        button.layer.cornerRadius = 15
        button.titleEdgeInsets = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        button.isEnabled = true
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(ButtonEvent(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var arrButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("summaryArr".localized(), for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        button.titleLabel?.contentMode = .center
        button.backgroundColor = .white
        button.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0).cgColor
        button.layer.borderWidth = 3
        button.layer.cornerRadius = 15
        
        button.titleEdgeInsets = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        button.isEnabled = true
        button.isUserInteractionEnabled = true
        
        button.addTarget(self, action: #selector(ButtonEvent(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    
    private lazy var calorieButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("summaryCal".localized(), for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        button.titleLabel?.contentMode = .center
        button.backgroundColor = .white
        button.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0).cgColor
        button.layer.borderWidth = 3
        button.layer.cornerRadius = 15
        
        button.titleEdgeInsets = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        
        button.isEnabled = true
        button.isUserInteractionEnabled = true
        
        button.addTarget(self, action: #selector(ButtonEvent(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    private lazy var stepButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("summaryStep".localized(), for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        button.titleLabel?.contentMode = .center
        button.backgroundColor = .white
        button.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0).cgColor
        button.layer.borderWidth = 3
        button.layer.cornerRadius = 15
        
        button.titleEdgeInsets = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        
        button.isEnabled = true
        button.isUserInteractionEnabled = true
        
        button.addTarget(self, action: #selector(ButtonEvent(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var hrvButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("summaryHRV".localized(), for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        button.titleLabel?.contentMode = .center
        button.backgroundColor = .white
        button.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0).cgColor
        button.layer.borderWidth = 3
        button.layer.cornerRadius = 15
        
        button.titleEdgeInsets = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        
        button.isEnabled = true
        button.isUserInteractionEnabled = true
        
        button.addTarget(self, action: #selector(ButtonEvent(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @objc private func ButtonEvent(_ sender: UIButton) {
        
//        setButtonColor(sender)
//        
//        switch(sender.tag) {
//        case BPM_BUTTON_TAG:
//            setChild(selectChild: bpmView, in: self.view)
//        case ARR_BUTTON_TAG:
//            setChild(selectChild: arrView, in: self.view)
//        case HRV_BUTTON_TAG:
//            setChild(selectChild: hrvView, in: self.view)
//        case CAL_BUTTON_TAG:
//            setChild(selectChild: calView, in: self.view)
//        case STEP_BUTTON_TAG:
//            setChild(selectChild: stepView, in: self.view)
//        default:
//            break
//        }
    }
    
    private func setChild(selectChild: UIViewController, in containerView: UIView) {
//        for child in childs {
//            if child == selectChild {
//                addChild(child, in: containerView)
//            } else {
//                removeChild(child)
//            }
//        }
    }
}

