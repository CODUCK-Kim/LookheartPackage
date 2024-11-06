//
//  File.swift
//  
//
//  Created by KHJ on 11/6/24.
//

import Foundation
import UIKit

class BasicAlertView: UIView {
    private let uiFactory = DependencyInjection.shared.resolve(UIFactory.self) ?? UIFactory.shared
    
    private let alertTitle: String
    private let alertBody: String
    private let alertOk: String
    
    lazy var okButton = uiFactory.button(
        title: alertOk,
        titleColor: .white,
        size: 14,
        weight: .heavy,
        backgroundColor: UIColor.MY_BLUE,
        cornerRadius: 10
    ).then {
        $0.titleLabel?.textAlignment = .center
    }
    
    // MARK: - init
    init(
        title: String,
        body: String,
        ok: String
    ) {
        self.alertTitle = title
        self.alertBody = body
        self.alertOk = ok
        
        super.init(frame: .zero)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let background = uiFactory.backgroundLabel(
            backgroundColor: .white,
            borderColor: UIColor.clear.cgColor,
            borderWidth: 0,
            cornerRadius: 20
        )
        
        let title = uiFactory.label(
            text: alertTitle,
            color: .MY_BLUE,
            font: UIFont.systemFont(ofSize: 16, weight: .heavy)
        )
         
        let body = uiFactory.label(
            text: alertBody,
            color: .black,
            font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ).then {
            $0.textAlignment = .center
        }
        
        let underLine = uiFactory.backgroundLabel(
            backgroundColor: .MY_LIGHT_BLUE,
            borderColor: UIColor.clear.cgColor,
            borderWidth: 0,
            cornerRadius: 0
        )
        
        
        // addSubview
        addSubview(background)
        addSubview(title)
        addSubview(underLine)
        addSubview(body)
        addSubview(okButton)

        
        // makeConstraints
        background.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        title.snp.makeConstraints { make in
            make.top.equalTo(background).offset(10)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
        }
        
        underLine.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom)
            make.left.equalTo(background).offset(10)
            make.right.equalTo(background).offset(-10)
            make.height.equalTo(2)
        }
        
        okButton.snp.makeConstraints { make in
            make.left.equalTo(background).offset(15)
            make.right.equalTo(background).offset(-15)
            make.bottom.equalTo(background).offset(-10)
            make.height.equalTo(30)
        }
        
        body.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom)
            make.left.equalTo(background).offset(10)
            make.right.equalTo(background).offset(-10)
            make.bottom.equalTo(okButton.snp.top)
        }
    }
}
