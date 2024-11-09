//
//  SelectAuthTypeViewController.swift
//  AuthFeature
//
//  Created by choijunios on 6/30/24.
//

import UIKit
import DSKit
import PresentationCore
import BaseFeature
import Domain


import RxSwift
import RxCocoa

class SelectAuthTypeViewController: BaseViewController {
    
    // View
    let titleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Heading1)
        label.textString = "쉽고 빠르게 만나는\n집 근처 요양 일자리, 케어밋"
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()
    
    let startAsCenterButton: AuthSelectionButton = {
        let button = AuthSelectionButton(initialState: .normal, titleText: "센터 관리자로\n시작하기", image: DSIcon.centerLogo.image)
        return button
    }()
    
    let startAsWorkerButton: AuthSelectionButton = {
        let button = AuthSelectionButton(initialState: .normal, titleText: "요양 보호사로\n시작하기", image: DSIcon.workerLogo.image)
        return button
    }()
    
    // MARK: Center view
    private let registerAsCenterButton: IdlePrimaryButton = {
        let button = IdlePrimaryButton(level: .large)
        button.label.textString = "회원가입하고 시작하기"
        button.alpha = 0
        return button
    }()
    private let loginAsCenterLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        label.textString = "이미 아이디가 있으신가요?"
        label.attrTextColor = DSKitAsset.Colors.gray300.color
        label.alpha = 0
        return label
    }()
    private let loginAsCenterButton: TextButtonType3 = {
        let button = TextButtonType3(typography: .Subtitle4)
        button.textString = "로그인하기"
        button.alpha = 0
        button.attrTextColor = DSKitAsset.Colors.orange500.color
        return button
    }()
    
    // MARK: Worker view
    private let registerAsWorkerButton: IdlePrimaryButton = {
        let button = IdlePrimaryButton(level: .large)
        button.label.textString = "휴대폰 번호로 시작하기"
        button.alpha = 0
        return button
    }()
    
    init() { 
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setApearance()
        setAutoLayout()
        setObservable()
    }
    
    func setApearance() {
        
        view.backgroundColor = DSColor.gray0.color
    }
    
    func setAutoLayout() {
        
        let selectAuthButtonStack = HStack([startAsCenterButton, startAsWorkerButton], spacing: 8, distribution: .fillEqually)
        
        let centerLoginContainer = HStack([loginAsCenterLabel, loginAsCenterButton], spacing: 12)
        [
            titleLabel,
            selectAuthButtonStack,
            centerLoginContainer,
            registerAsCenterButton,
            registerAsWorkerButton,
        ]
        .forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 80.47),
            titleLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 21),
            
            selectAuthButtonStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            selectAuthButtonStack.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            selectAuthButtonStack.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
            
            centerLoginContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerLoginContainer.bottomAnchor.constraint(equalTo: registerAsCenterButton.topAnchor, constant: -12),
            
            registerAsCenterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -14),
            registerAsCenterButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
            registerAsCenterButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20),
            
            registerAsWorkerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -14),
            registerAsWorkerButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
            registerAsWorkerButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20),
        ])
    }
    
    func setObservable() { 
        
        Observable<UserType>
            .merge(
                startAsCenterButton.rx.tap.asObservable().map({ _ in .center }),
                startAsWorkerButton.rx.tap.asObservable().map({ _ in .worker })
            )
            .subscribe(onNext: { [weak self] userType in
                
                guard let self else { return }
                
                UIView.animate(withDuration: 0.35) {
                    
                    // selection button
                    if userType == .center {
                        self.startAsWorkerButton.setState(.normal)
                    } else {
                        self.startAsCenterButton.setState(.normal)
                    }
                    
                    // Show buttons
                    self.setEnableCenterPart(userType == .center)
                    self.setEnableWorkerPart(userType == .worker)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func setEnableCenterPart(_ isEnable: Bool) {
        self.registerAsCenterButton.alpha = isEnable ? 1 : 0
        self.loginAsCenterLabel.alpha = isEnable ? 1 : 0
        self.loginAsCenterButton.alpha = isEnable ? 1 : 0
    }
    
    private func setEnableWorkerPart(_ isEnable: Bool) {
        self.registerAsWorkerButton.alpha = isEnable ? 1 : 0
    }
    
    public func bind(viewModel: SelectAuthTypeViewModel) {
        
        super.bind(viewModel: viewModel)
        
        loginAsCenterButton.eventPublisher
            .bind(to: viewModel.loginAsCenterButtonClicked)
            .disposed(by: disposeBag)
        
        registerAsCenterButton
            .rx.tap
            .bind(to: viewModel.registerAsCenterButtonClicked)
            .disposed(by: disposeBag)
        
        registerAsWorkerButton
            .rx.tap
            .bind(to: viewModel.registerAsWorkerButtonClicked)
            .disposed(by: disposeBag)
    }
}
