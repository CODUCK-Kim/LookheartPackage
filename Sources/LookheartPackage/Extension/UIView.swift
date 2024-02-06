import UIKit

extension UIView {
    // 현재 뷰 컨트롤러에 접근
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

// 최상위 Scene 찾기
extension UIApplication {
    @available(iOS 13.0, *)
    public func topMostViewController() -> UIViewController? {
        // 현재 활성화된 scene 찾기 (일반적으로 foregroundActive 상태인 scene)
        guard let currentWindowScene = self.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else { return nil }
        
        // 찾은 scene에서 rootViewController 찾기
        guard let rootViewController = currentWindowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else { return nil }
        
        // 최상위 뷰 컨트롤러 반환
        return rootViewController.topMostViewController()
    }
}

extension UIViewController {
    public func topMostViewController() -> UIViewController {
        if let presented = self.presentedViewController {
            return presented.topMostViewController()
        }
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? navigation
        }
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        return self
    }
}
