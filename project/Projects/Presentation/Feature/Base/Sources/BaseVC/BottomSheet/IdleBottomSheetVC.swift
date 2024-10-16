//
//  IdleBottomSheetVC.swift
//  BaseFeature
//
//  Created by choijunios on 8/28/24.
//

import UIKit
import Domain
import PresentationCore
import DSKit


import RxSwift
import RxCocoa

open class IdleBottomSheetVC: BaseViewController {
    
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
    let tapToDismissSpace = UIView()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        setGesture()
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    open override func viewDidLoad() {
        setAppearance()
    }
    
    func setAppearance() {
        
        view.backgroundColor = .black.withAlphaComponent(0.0)
    }
    
    public func setLayout(contentView: UIView, margin: UIEdgeInsets = .init(top: 0, left: 27, bottom: 80, right: 27)) {
        
        sheetView.backgroundColor = .white
        sheetView.layer.cornerRadius = 16.0
        sheetView.layoutMargins = margin
        
        [
            dragSpace,
            contentView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            sheetView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            
            dragSpace.topAnchor.constraint(equalTo: sheetView.layoutMarginsGuide.topAnchor),
            dragSpace.leftAnchor.constraint(equalTo: sheetView.leftAnchor),
            dragSpace.rightAnchor.constraint(equalTo: sheetView.rightAnchor),
            
            contentView.topAnchor.constraint(equalTo: dragSpace.bottomAnchor),
            contentView.leftAnchor.constraint(equalTo: sheetView.layoutMarginsGuide.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: sheetView.layoutMarginsGuide.rightAnchor),
            contentView.bottomAnchor.constraint(equalTo: sheetView.layoutMarginsGuide.bottomAnchor),
        ])
        
        [
            tapToDismissSpace,
            sheetView,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            
            tapToDismissSpace.topAnchor.constraint(equalTo: view.topAnchor),
            tapToDismissSpace.leftAnchor.constraint(equalTo: view.leftAnchor),
            tapToDismissSpace.rightAnchor.constraint(equalTo: view.rightAnchor),
            tapToDismissSpace.bottomAnchor.constraint(equalTo: sheetView.topAnchor),
            
            sheetView.rightAnchor.constraint(equalTo: view.rightAnchor),
            sheetView.leftAnchor.constraint(equalTo: view.leftAnchor),
            sheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 16)
        ])
    }
    
    func setGesture() {
        
        // MARK: 드래그
        let dragRecognizer = UIPanGestureRecognizer()
        dragRecognizer.addTarget(self, action: #selector(onPanGesture(_:)))
        
        dragSpace.addGestureRecognizer(dragRecognizer)
        
        // MARK: 탭
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(tapForDismiss(_:)))
        
        tapToDismissSpace.addGestureRecognizer(tapGesture)
    }
}

/// 뷰 디스플레이 관련
extension IdleBottomSheetVC {
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 애니메이션 시작전에 해당뷰를 화면 밖으로 이동한다.
        sheetView.transform = .init(translationX: 0, y: 1000)
    }
    
    /// viewDidAppear서브 뷰들의 레이아웃이 결정된 이후 시점(화면상에 나타난 시점)으로, frame, bounds에 근거있는 값들이 할당된 이후이다.
    public override func viewDidAppear(_ animated: Bool) {
        
        view.backgroundColor = .black.withAlphaComponent(0.0)
        let height = sheetView.bounds.height
        sheetView.isUserInteractionEnabled = false
        sheetView.transform = .init(translationX: 0, y: height)
        
        UIView.animate(withDuration: 0.35) { [sheetView, view] in
            sheetView.transform = .identity
            view?.backgroundColor = .black.withAlphaComponent(0.5)
        } completion: { [sheetView] _ in
            sheetView.isUserInteractionEnabled = true
        }
    }
    
    public func dismissView(onDismissFinished: (() -> ())? = nil) {
        
        let height = sheetView.bounds.height
        sheetView.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.2) { [sheetView, view] in
            sheetView.transform = .init(translationX: 0, y: height)
            view?.backgroundColor = .black.withAlphaComponent(0.0)
        } completion: { [weak self] _ in
            self?.dismiss(animated: false, completion: {
                onDismissFinished?()
            })
        }
    }
}

/// 제스처 동작
extension IdleBottomSheetVC {
    
    @objc
    func tapForDismiss(_ gesture: UITapGestureRecognizer) {
        
        var tapArea = view.frame
        tapArea.size.height = sheetView.frame.origin.y
        
        let loc = gesture.location(in: view)
        
        if tapArea.contains(loc) {
            dismissView()
        }
    }
    
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
