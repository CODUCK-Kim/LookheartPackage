import UIKit

public class KeyboardEventHandling {
    weak var scrollView: UIScrollView?
    weak var view: UIView?
    
    public init(scrollView: UIScrollView? = nil) {
        self.scrollView = scrollView
    }
    
    public func setScrollView(
        scrollView: UIScrollView,
        view: UIView
    ) {
        self.scrollView = scrollView
        self.view = view
    }
    
    public func startObserving() {
        if view == nil {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(viewKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)            
        }
    }
    
    public func stopObserving() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let scrollView = scrollView else { return }
        
        let contentInset = UIEdgeInsets(
            top: 0.0,
            left: 0.0,
            bottom: keyboardFrame.size.height,
            right: 0.0
        )
        
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
    }
    
    @objc private func viewKeyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let scrollView = scrollView,
              let view = view else { return }
        
        // 키보드 프레임을 뷰의 좌표계로 변환
        let keyboardFrame = keyboardFrameValue.cgRectValue
        let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
        
        // 안전 영역의 bottom 값 가져오기
        let bottomSafeAreaInset = view.safeAreaInsets.bottom
        
        let contentInset = UIEdgeInsets(
            top: 0.0,
            left: 0.0,
            bottom: keyboardFrameInView.height - bottomSafeAreaInset,
            right: 0.0
        )
        
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        guard let scrollView = scrollView else { return }
        
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
}
