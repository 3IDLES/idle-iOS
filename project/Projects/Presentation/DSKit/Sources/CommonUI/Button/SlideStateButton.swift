//
//  SlideStateButton.swift
//  DSKit
//
//  Created by choijunios on 8/10/24.
//

import Foundation
import UIKit
import PresentationCore
import RxCocoa
import RxSwift
import Entity

public class SlideStateButton: UIView {
    
    public enum State {
        case state1
        case state2
    }
    
    // Init
    
    // View
    public let state1Label: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        return label
    }()
    public let state2Label: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        return label
    }()
    
    let contentView: UIView = .init()
    
    let accentBackgroundView: UIView = {
        let view = UIView()
        return view
    }()
    
    let idleTextColor = DSKitAsset.Colors.gray300.color
    let accentTextColor = DSKitAsset.Colors.gray900.color
    
    lazy var state1Anchor: NSLayoutConstraint = accentBackgroundView.centerXAnchor.constraint(equalTo: state1Label.centerXAnchor)
    lazy var state2Anchor: NSLayoutConstraint = accentBackgroundView.centerXAnchor.constraint(equalTo: state2Label.centerXAnchor)
    
    // Observable
    /// 핫옵저버블 입니다.
    public lazy var signal: Single<State> = stateObservable.asSingle()
    
    private let stateObservable: PublishRelay<State> = .init()
    private let disposeBag = DisposeBag()
    
    public override var intrinsicContentSize: CGSize {
        .init(width: 186, height: 36)
    }
    
    public init(initialState: State = .state1) {
        super.init(frame: .zero)
        
        setAppearance()
        setLayout()
        setObservable()
        setGesture()
        
        setState(initialState)
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    private func setAppearance() {
        self.backgroundColor = DSKitAsset.Colors.gray050.color
        self.layer.cornerRadius = 18
        self.clipsToBounds = true
        
        contentView.backgroundColor = DSKitAsset.Colors.gray050.color
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        
        accentBackgroundView.backgroundColor = .white
        accentBackgroundView.layer.cornerRadius = 16
    }
    
    private func setLayout() {
        
        [
            accentBackgroundView,
            state1Label,
            state2Label
        ].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            state1Label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -45.5),
            state1Label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            state2Label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 45.5),
            state2Label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            accentBackgroundView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            accentBackgroundView.widthAnchor.constraint(equalToConstant: 100),
            accentBackgroundView.heightAnchor.constraint(equalToConstant: 32),
        ])
        
        
        [
            contentView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(contentView)
        }
        
        NSLayoutConstraint.activate([
            
            contentView.topAnchor.constraint(equalTo: self.topAnchor, constant: 2),
            contentView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 2),
            contentView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -2),
            contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2),
        ])
    }
    
    private func setObservable() {
        
        
    }
    
    private func setGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped(_:)))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func labelTapped(_ sender: UITapGestureRecognizer) {
        
        guard let senderView = sender.view else { return }
        
        let touchLocation = sender.location(in: senderView)
        
        let currentState: State = touchLocation.x < senderView.bounds.width/2 ? .state1 : .state2
        
        stateObservable.accept(currentState)
        
        // State change
        UIView.animate(withDuration: 0.35) { [weak self] in
            
            guard let self else { return }
            
            setState(currentState)
            
            layoutIfNeeded()
        }
    }
    
    public func setState(_ state: State) {
        
        state1Label.attrTextColor = state == .state1 ? accentTextColor : idleTextColor
        state2Label.attrTextColor = state == .state2 ? accentTextColor : idleTextColor
        
        state1Anchor.isActive = state == .state1
        state2Anchor.isActive = state == .state2
    }
}

@available(iOS 17.0, *)
#Preview("Preview", traits: .defaultLayout) {
    
    let btn = SlideStateButton(initialState: .state1)
    btn.state1Label.textString = "휴식중"
    btn.state2Label.textString = "구직중"
    
    return btn
}
