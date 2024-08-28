//
//  IdleBigAlertController.swift
//  DSKit
//
//  Created by choijunios on 7/25/24.
//

import UIKit
import RxSwift
import RxCocoa
import Entity

public protocol IdleAlertViewModelable {
    
    var acceptButtonClicked: PublishRelay<Void> { get }
    var cancelButtonClicked: PublishRelay<Void> { get }
    var acceptButtonLabelText: String { get }
    var cancelButtonLabelText: String { get }
    var dismiss: Driver<Void>? { get }
    var title: String { get }
    var description: String { get }
}

public class DefaultIdleAlertVM: IdleAlertViewModelable {
    
    public let title: String
    public let description: String
    public let acceptButtonLabelText: String
    public let cancelButtonLabelText: String
    
    public let acceptButtonClicked: RxRelay.PublishRelay<Void> = .init()
    public let cancelButtonClicked: RxRelay.PublishRelay<Void> = .init()
     
    public let dismiss: RxCocoa.Driver<Void>?
    
    public init(
        title: String,
        description: String,
        acceptButtonLabelText: String,
        cancelButtonLabelText: String,
        onAccepted: (() -> ())? = nil
    ) {
        self.title = title
        self.description = description
        self.acceptButtonLabelText = acceptButtonLabelText
        self.cancelButtonLabelText = cancelButtonLabelText
        
        dismiss = Observable
            .merge(
                acceptButtonClicked
                    .map({ _ in onAccepted?() })
                    .asObservable(),
                cancelButtonClicked.asObservable()
            )
            .asDriver(onErrorDriveWith: .never())
    }
}


public class IdleBigAlertController: UIViewController {
    
    let customTranstionDelegate = CustomTransitionDelegate()
    
    // Not init
    private let disposeBag = DisposeBag()
    
    // View
    let titleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle1)
        label.textAlignment = .center
        return label
    }()
    
    let descriptionLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        label.attrTextColor = DSKitAsset.Colors.gray500.color
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    public let cancelButton: IdleThirdinaryButton = {
        let button = IdleThirdinaryButton(level: .medium)
        button.label.textString = ""
        return button
    }()
    public let acceptButton: IdlePrimaryButton = {
        let button = IdlePrimaryButton(level: .mediumRed)
        button.label.textString = ""
        return button
    }()
    
    public init() {
        
        super.init(nibName: nil, bundle: nil)
        
        self.transitioningDelegate = customTranstionDelegate
        
        setAppearance()
        setAutoLayout()
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    private func setAppearance() {
        view.backgroundColor = DSKitAsset.Colors.gray500.color.withAlphaComponent(0.5)
        
        // TODO: 미정으로 변동가능합니다.
        view.layoutMargins = .init(top: 0, left: 24, bottom: 0, right: 24)
    }
    
    private func setAutoLayout() {
        
        // 라벨 스택
        let textStack = VStack(
            [
                Spacer(height: 8),
                titleLabel
            ],
            spacing: 8,
            alignment: .center
        )
        
        // 버튼 스택
        let buttonStack = HStack(
            [
                cancelButton,
                acceptButton
            ],
            spacing: 8,
            alignment: .fill,
            distribution: .fillEqually
        )

        // 라벨 + 버튼 스택
        let alertContentsStack = VStack(
            [
                HStack([
                    Spacer(width: 41.5),
                    textStack,
                    Spacer(width: 41.5)
                ], alignment: .fill),
                buttonStack
            ],
            spacing: 24,
            alignment: .fill
        )

        NSLayoutConstraint.activate([
            // 버튼 스택 높이 지정
            buttonStack.heightAnchor.constraint(equalToConstant: 52),
            
        ])
        
        // 전체 스택
        let alertContainer = UIView()
        alertContainer.backgroundColor = .white
        alertContainer.layer.cornerRadius = 12
        alertContainer.clipsToBounds = true
        
        alertContainer.layoutMargins = .init(top: 20, left: 12, bottom: 12, right: 12)
        
        [
            alertContentsStack
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            alertContainer.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            alertContentsStack.topAnchor.constraint(equalTo: alertContainer.layoutMarginsGuide.topAnchor),
            alertContentsStack.leadingAnchor.constraint(equalTo: alertContainer.layoutMarginsGuide.leadingAnchor),
            alertContentsStack.trailingAnchor.constraint(equalTo: alertContainer.layoutMarginsGuide.trailingAnchor),
            alertContentsStack.bottomAnchor.constraint(equalTo: alertContainer.layoutMarginsGuide.bottomAnchor),
        ])
        
        // 컨트롤러 뷰
        [
            alertContainer
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            alertContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            alertContainer.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            alertContainer.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        ])
    }
    
    public func bind(viewModel vm: IdleAlertViewModelable) {
        
        titleLabel.textString = vm.title
        descriptionLabel.textString = vm.description
        
        acceptButton.label.textString = vm.acceptButtonLabelText
        cancelButton.label.textString = vm.cancelButtonLabelText
        
        vm.dismiss?
            .drive(onNext: { [weak self] in
                
                guard let self else { return }
                modalPresentationStyle = .custom
                dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        acceptButton.rx.tap
            .bind(to: vm.acceptButtonClicked)
            .disposed(by: disposeBag)
        
        cancelButton
            .rx.tap
            .bind(to: vm.cancelButtonClicked)
            .disposed(by: disposeBag)
    }
}

class FadeInAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35 // 애니메이션 지속 시간
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(fromView)
        
        // 애니메이션 시작 상태 설정
        fromView.alpha = 1.0
        
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            // 애니메이션 적용
            fromView.alpha = 0.0
        }) { _ in
            // 애니메이션 완료 후 처리
            fromView.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

class FadeOutAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35 // 애니메이션 지속 시간
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to) else { return }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(toView)
        
        // 애니메이션 시작 상태 설정
        toView.alpha = 0.0
        
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            // 애니메이션 적용
            toView.alpha = 1.0
        }) { _ in
            // 애니메이션 완료 후 처리
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

class CustomTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadeInAnimator() // 우리가 만든 사용자 정의 애니메이터를 반환
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        return FadeOutAnimator()
    }
}


@available(iOS 17.0, *)
#Preview("Preview", traits: .defaultLayout) {
    
    IdleBigAlertController()
}
