//
//  AuthStateDisplayVC.swift
//  CenterFeature
//
//  Created by choijunios on 9/11/24.
//

import UIKit
import BaseFeature
import PresentationCore
import RxCocoa
import RxSwift
import Entity
import DSKit

public class AuthStateDisplayVC: BaseViewController {
    
    public enum AuthState {
        case authIsOnGoing
        case requestCenterInfo
        
        var titleLabelText: String {
            switch self {
            case .authIsOnGoing:
                "인증 진행 중이에요.\n잠시만 기다려주세요."
            case .requestCenterInfo:
                "센터 정보 입력 후\n이용할 수 있어요."
            }
        }
    }
    
    // Init
    let currentState: AuthState
    
    // View
    let titleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Heading1)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    let insertCenterInfoButton: IdlePrimaryButton = {
        let button = IdlePrimaryButton(level: .large)
        button.label.textString = "센터 정보 입력하기"
        return button
    }()
    
    public init(state: AuthState) {
        self.currentState = state
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setAppearance()
        setLayout()
        setObservable()
    }
    
    private func setAppearance() {
        view.backgroundColor = DSColor.gray0.color
        
        titleLabel.textString = currentState.titleLabelText
        insertCenterInfoButton.isHidden = currentState == .authIsOnGoing
    }
    
    private func setLayout() {
        
        let mainStack = VStack([
            titleLabel,
            insertCenterInfoButton
        ], spacing: 24, alignment: .fill)
        
        [
            mainStack
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            mainStack.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
            mainStack.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20),
            mainStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    private func setObservable() {
        
    }
}


@available(iOS 17.0, *)
#Preview("Preview", traits: .defaultLayout) {
    
    AuthStateDisplayVC(state: .authIsOnGoing)
}
