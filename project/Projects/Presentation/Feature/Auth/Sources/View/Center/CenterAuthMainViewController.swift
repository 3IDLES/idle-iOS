//
//  CenterAuthMainViewController.swift
//  AuthFeature
//
//  Created by choijunios on 7/1/24.
//

import UIKit
import Entity
import DSKit
import RxSwift
import RxCocoa
import PresentationCore
import BaseFeature

public class CenterAuthMainViewController: DisposableViewController {
    
    var coordinator: CenterAuthMainCoordinator?
    
    private let titleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Heading1)
        label.textString = "센터장님, 환영합니다!"
        return label
    }()
    private let titleImage: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .cyan
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let loginQuestionLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        label.textString = "이미 아이디가 있으신가요?"
        label.attrTextColor = DSKitAsset.Colors.gray300.color
        return label
    }()
    private let loginButton: TextButtonType3 = {
        let btn = TextButtonType3(typography: .Subtitle4)
        btn.textString = "로그인하기"
        btn.attrTextColor = DSKitAsset.Colors.orange500.color
        return btn
    }()
    
    private let ctaButton: CTAButtonType1 = {
        
        let button = CTAButtonType1(labelText: "회원가입하고 시작하기")
        
        return button
    }()
    
    let disposeBag = DisposeBag()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        setAppearance()
        setAutoLayout()
        setObservable()
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func setAppearance() {
        view.backgroundColor = .white
        view.layoutMargins = .init(top: 0, left: 20, bottom: 16, right: 20)
    }
    
    func setAutoLayout() {
        
        let titleStack = VStack([
            titleLabel,
            titleImage
        ], spacing: 32,alignment: .center)
        
        let titleStackCenteringView = UIView()
        titleStackCenteringView.backgroundColor = .clear
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        titleStackCenteringView.addSubview(titleStack)
        
        
        let loginStack = UIStackView()
        loginStack.axis = .horizontal
        loginStack.spacing = 6
        loginStack.distribution = .fill
        loginStack.alignment = .center
        [
            loginQuestionLabel,
            loginButton
        ].forEach {
            loginStack.addArrangedSubview($0)
        }
        
        [
            titleStackCenteringView,
            loginStack,
            ctaButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            
            titleStack.centerXAnchor.constraint(equalTo: titleStackCenteringView.centerXAnchor),
            titleStack.centerYAnchor.constraint(equalTo: titleStackCenteringView.centerYAnchor),
            
            titleImage.widthAnchor.constraint(equalToConstant: 120),
            titleImage.heightAnchor.constraint(equalTo: titleImage.widthAnchor),
            
            titleStackCenteringView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleStackCenteringView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            titleStackCenteringView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            titleStackCenteringView.bottomAnchor.constraint(equalTo: loginStack.topAnchor),
            
            loginStack.bottomAnchor.constraint(equalTo: ctaButton.topAnchor, constant: -16),
            loginStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        
            ctaButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            ctaButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            ctaButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
        ])
    }
    
    func setObservable() {
        
        loginButton
            .eventPublisher
            .subscribe { [weak self] _ in
                self?.coordinator?.parent?.login()
            }
            .disposed(by: disposeBag)
        
        ctaButton
            .eventPublisher
            .subscribe(onNext: { [weak self] _ in
                self?.coordinator?.parent?.register()
            })
            .disposed(by: disposeBag)
    }

    public func cleanUp() {
        
    }
}
