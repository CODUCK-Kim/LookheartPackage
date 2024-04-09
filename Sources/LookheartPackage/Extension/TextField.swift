//
//  File.swift
//  
//
//  Created by 정연호 on 2024/04/09.
//

import Foundation
import UIKit
import Combine

extension UITextField {
    @available(iOS 13.0, *)
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self)
            .compactMap { $0.object as? UITextField }
            .map { $0.text ?? "" }
            .eraseToAnyPublisher()
    }
}
