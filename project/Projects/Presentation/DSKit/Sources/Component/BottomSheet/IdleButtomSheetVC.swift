//
//  File.swift
//  DSKit
//
//  Created by choijunios on 8/8/24.
//

import UIKit
import RxSwift
import RxCocoa
import Entity
import PresentationCore

public class IdleButtomSheetVC: UIViewController {
    
    // Not init
    private var gestureBeganPosition: CGPoint = .zero
    private var lastGesturePosition: CGPoint = .zero
    
    let dragSpace: UIView = {
        let bar = UIView()
        bar.backgroundColor = DSKitAsset.Colors.gray200.color
        bar.layer.cornerRadius = 2
        
        let space = UIView()
        
        space.addSubview(bar)
        bar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bar.heightAnchor.constraint(equalToConstant: 4),
            bar.widthAnchor.constraint(equalToConstant: 55),
            bar.centerXAnchor.constraint(equalTo: space.centerXAnchor),
            bar.topAnchor.constraint(equalTo: space.topAnchor, constant: 13),
            bar.bottomAnchor.constraint(equalTo: space.bottomAnchor, constant: -19),
        ])
        
        return space
    }()
    
    let sheetView = UIView()
    
    func setAppearance() {
        
        view.backgroundColor = .black.withAlphaComponent(0.0)
    }
    
    func setLayout(contentView: UIView) {
        
        let conerRadius = 16.0
        
        sheetView.backgroundColor = .white
        sheetView.layer.cornerRadius = conerRadius
        sheetView.layoutMargins = .init(top: 0, left: 27, bottom: 64 + conerRadius, right: 27)
        
        let label = IdleLabel(typography: .Heading3)
        label.textString = "접수 마감일"
        label.textAlignment = .center
        
        let stack = VStack(
            [
                label,
                contentView
            ],
            spacing: 31,
            alignment: .fill
        )
        
        [
            dragSpace,
            stack
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            sheetView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            
            dragSpace.topAnchor.constraint(equalTo: sheetView.layoutMarginsGuide.topAnchor),
            dragSpace.leftAnchor.constraint(equalTo: sheetView.leftAnchor),
            dragSpace.rightAnchor.constraint(equalTo: sheetView.rightAnchor),
            
            stack.topAnchor.constraint(equalTo: dragSpace.bottomAnchor),
            stack.leftAnchor.constraint(equalTo: sheetView.layoutMarginsGuide.leftAnchor),
            stack.rightAnchor.constraint(equalTo: sheetView.layoutMarginsGuide.rightAnchor),
            stack.bottomAnchor.constraint(equalTo: sheetView.layoutMarginsGuide.bottomAnchor),
        ])
        
        [
            sheetView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            sheetView.rightAnchor.constraint(equalTo: view.rightAnchor),
            sheetView.leftAnchor.constraint(equalTo: view.leftAnchor),
            sheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: conerRadius)
        ])
    }
    
    func setGesture() {
        
        let recognizer = UIPanGestureRecognizer()
        recognizer.addTarget(self, action: #selector(onPanGesture(_:)))
        
        view.addGestureRecognizer(recognizer)
    }
}

/// 뷰 디스플레이 관련
extension IdleButtomSheetVC {
    
    /// viewDidAppear서브 뷰들의 레이아웃이 결정된 이후 시점(화면상에 나타난 시점)으로, frame, bounds에 근거있는 값들이 할당된 이후이다.
    public override func viewDidAppear(_ animated: Bool) {
        
        view.backgroundColor = .black.withAlphaComponent(0.0)
        let height = sheetView.bounds.height
        sheetView.isUserInteractionEnabled = false
        sheetView.transform = .init(translationX: 0, y: height)
        
        UIView.animate(withDuration: 0.35) { [sheetView, weak view] in
            sheetView.transform = .identity
            view?.backgroundColor = .black.withAlphaComponent(0.5)
        } completion: { [sheetView] _ in
            sheetView.isUserInteractionEnabled = true
        }
    }
    
    func dismissView() {
        
        let height = sheetView.bounds.height
        sheetView.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.2) { [sheetView, weak view] in
            sheetView.transform = .init(translationX: 0, y: height)
            view?.backgroundColor = .black.withAlphaComponent(0.0)
        } completion: { [weak self] _ in
            self?.dismiss(animated: false)
        }
    }
}

/// 제스처 동작
extension IdleButtomSheetVC {
    
    @objc
    func onPanGesture(_ gesture: UIPanGestureRecognizer) {
        
        let currentTouchPos = gesture.numberOfTouches > 0 ? gesture.location(ofTouch: 0, in: view) : .zero
        
        switch gesture.state {
        case .began:
            // 드래그 스페이스 내에서 드래그를 해야함
            gestureBeganPosition = currentTouchPos
            
        case .changed:
            
            lastGesturePosition = currentTouchPos
            
            let moveDistance = currentTouchPos.y - gestureBeganPosition.y
            
            if moveDistance >= 0 {
                // 제스처를 아래로 한 경우
                sheetView.transform = .init(translationX: 0, y: moveDistance)
            }
 
        case .ended, .cancelled:
            
            let moveDistance = lastGesturePosition.y-gestureBeganPosition.y
            
            if moveDistance >= 65 {
                // 특정 길이만큼 드래그한 경우, 화면닫기
                dismissView()
                
            } else {
                UIView.animate(withDuration: 0.35) { [sheetView] in
                    sheetView.transform = .identity
                }
            }
            
        default:
            return;
        }
    }
}
