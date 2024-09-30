//
//  KeyboardAvoidance.swift
//  PresentationCore
//
//  Created by choijunios on 8/1/24.
//

import UIKit
import RxSwift

public protocol IdleKeyboardAvoidable where Self: UIView {
    
    var movingView: UIView? { get set }
    var disposeBag: DisposeBag { get }
    var prevRect: CGRect { get set }
    var isPushed: Bool { get set }
}

public extension IdleKeyboardAvoidable {
    
    func setKeyboardAvoidance(movingView: UIView) {
        
        self.movingView = movingView
        
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .subscribe { [weak self] noti in
                self?.onKeyboardAction(noti)
            }
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillHideNotification)
            .subscribe { [weak self] noti in
                self?.onKeyboardActionFinished(noti)
            }
            .disposed(by: disposeBag)
    }
    
    private func onKeyboardAction(_ notification: Notification) {
        
        // FirstResponder인 경우만 키보드 이동을 실행
        if !self.isFirstResponder { return }
        
        guard let userInfo = notification.userInfo else { return }
        
        guard let keyWindow = UIApplication.shared.keyWindow,
              let movingView,
              let keyboardFrameEnd = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        // window의 좌표계를 획득
        let fromCoordinateSpace = keyWindow.coordinateSpace

        // 키보드의 좌표계를 특정 뷰의 좌표계로 변환
        let keyboardViewFrame = fromCoordinateSpace.convert(keyboardFrameEnd, to: movingView)
        
        // 현재 뷰의 Frame
        let viewFrame = self.convert(self.bounds, to: movingView)
        
        let viewHeightFromTop = viewFrame.origin.y + bounds.height
        
        if keyboardViewFrame.origin.y < viewHeightFromTop {
            
            // 키보드 이동 필요
            let diff = viewHeightFromTop - keyboardViewFrame.origin.y
            
            // 키보드 애니메이션 지속시간
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
            
            UIView.animate(withDuration: duration) {
                movingView.transform = CGAffineTransform(translationX: 0, y: -diff)
            } completion: { [weak self] _ in
                self?.isPushed = true
            }
        }
    }
    
    private func onKeyboardActionFinished(_ notification: Notification) {
        
        if !isPushed { return }
        
        isPushed = false
        
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        
        UIView.animate(withDuration: duration) { [weak movingView] in
            
            movingView?.transform = .identity
        }
    }
}
