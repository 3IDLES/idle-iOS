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

public class IdleAlertObject {
    
    public private(set) var title: String = ""
    public private(set) var description: String = ""
    public private(set) var acceptButtonLabelText: String = ""
    public private(set) var cancelButtonLabelText: String = ""
    
    public var acceptButtonClicked: Driver<Void>?
    public var cancelButtonClicked: Driver<Void>?
    
    public init() { }
    
    public func setTitle(_ text: String) -> Self {
        self.title = text
        return self
    }
    
    public func setDescription(_ text: String) -> Self {
        self.description = text
        return self
    }
    
    public func setAcceptButtonLabelText(_ text: String) -> Self {
        self.acceptButtonLabelText = text
        return self
    }
    
    public func setCancelButtonLabelText(_ text: String) -> Self {
        self.cancelButtonLabelText = text
        return self
    }
}


public class IdleBigAlertController: UIViewController {
    
    public enum ButtonType {
        case orange
        case red
    }
    
    let customTranstionDelegate = CustomTransitionDelegate()
    
    // Init
    let type: ButtonType
    
    // Not init
    private let disposeBag = DisposeBag()
    
    // View
    let titleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle1)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let descriptionLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        label.attrTextColor = DSKitAsset.Colors.gray500.color
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    public lazy var cancelButton: IdleThirdinaryButton = {
        let button = IdleThirdinaryButton(level: .medium)
        button.label.textString = ""
        return button
    }()
    public lazy var acceptButton: IdlePrimaryButton = {
        let button = IdlePrimaryButton(level: type == .orange ? .medium : .mediumRed)
        button.label.textString = ""
        return button
    }()
    
    public init(type: ButtonType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
        
        self.transitioningDelegate = customTranstionDelegate
        
        setAppearance()
        setAutoLayout()
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    private func setAppearance() {
        view.backgroundColor = DSKitAsset.Colors.gray500.color.withAlphaComponent(0.5)
    }
    
    private func setAutoLayout() {
        
        view.layoutMargins = .init(top: 0, left: 24, bottom: 0, right: 24)
        
        // 라벨 스택
        let textStack = VStack(
            [
                titleLabel,
                descriptionLabel
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
                textStack,
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
    
    public func bindObject(_ object: IdleAlertObject) {
        
        titleLabel.textString = object.title
        
        descriptionLabel.textString = object.description
        descriptionLabel.textAlignment = .center
        
        acceptButton.label.textString = object.acceptButtonLabelText
        cancelButton.label.textString = object.cancelButtonLabelText
        
        
        Observable.merge(
            acceptButton.rx.tap.asObservable(),
            cancelButton.rx.tap.asObservable()
        )
        .asDriver(onErrorDriveWith: .never())
        .drive(onNext: { [weak self] in
            
            guard let self else { return }
            modalPresentationStyle = .custom
            dismiss(animated: true)
        })
        .disposed(by: disposeBag)
        
        object.acceptButtonClicked = acceptButton
            .rx.tap.asDriver(onErrorDriveWith: .never())
            
        object.cancelButtonClicked = cancelButton
            .rx.tap.asDriver(onErrorDriveWith: .never())
    }
    
    public func bind(viewModel vm: IdleAlertViewModelable) {
        
        titleLabel.textString = vm.title
        titleLabel.textAlignment = .center
        descriptionLabel.textString = vm.description
        descriptionLabel.textAlignment = .center
        
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

public class FadeInAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35 // 애니메이션 지속 시간
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
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

public class FadeOutAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35 // 애니메이션 지속 시간
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
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

public class CustomTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadeInAnimator() // 우리가 만든 사용자 정의 애니메이터를 반환
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        return FadeOutAnimator()
    }
}


@available(iOS 17.0, *)
#Preview("Preview", traits: .defaultLayout) {
    
    IdleBigAlertController(type: .orange)
}
