//
//  File.swift
//  
//
//  Created by 정연호 on 2024/04/11.
//

import Foundation
import Network
import UIKit

@available(iOS 13.0, *)
public class NetworkMonitor {
    public static let shared = NetworkMonitor()
    private var monitor: NWPathMonitor?
    private let queue = DispatchQueue.global(qos: .background)

    public var isConnected: Bool = true {
        didSet {
            DispatchQueue.main.async {
                if self.isConnected {
                    // 네트워크 연결
                    UIApplication.shared.keyWindow?.rootViewController?.removeLoadingOverlay()
                } else {
                    // 네트워크 연결 끊김
                    UIApplication.shared.keyWindow?.rootViewController?.showLoadingOverlay()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        guard let viewController = UIApplication.shared.keyWindow?.rootViewController else { return }
                        
                        propAlert.basicCancelAlert(
                            title: "noti".localized(),
                            message: "nonNetworkHelpText".localized(),
                            ok: "ok".localized(),
                            cancel: "exit2".localized(),
                            viewController: viewController,
                            completion: {
                                UIApplication.shared.keyWindow?.rootViewController?.removeLoadingOverlay()
                            },
                            cancelAction: {
                                exit(0)
                            })
                    }
                }
            }
        }
    }

    init() {
        monitor = NWPathMonitor()
        monitor?.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
        monitor?.start(queue: queue)
        
    }
}

