//
//  EnterNameViewController.swift
//  AuthFeature
//
//  Created by choijunios on 6/30/24.
//

import UIKit
import DSKit
import RxSwift
import RxCocoa
import PresentationCore

public protocol EnterNameInputable {
    var name: Observable<String>? { get set }
}

public class EnterNameViewController<T: ViewModelType>: DisposableViewController
where T.Input: EnterNameInputable & CTAButtonEnableInputable, T.Output: CTAButtonEnableOutPutable {
    
    public var coordinator: Coordinator?
    
    private let viewModel: T
    
    // View
    private let processTitle: ResizableUILabel = {
       
        let label = ResizableUILabel()
        
        label.text = "성함을 입력해주세요."
        label.font = DSKitFontFamily.Pretendard.bold.font(size: 20)
        label.textAlignment = .left
        
        return label
    }()
    
    private let textField: IdleOneLineInputField = {
       
        let textField = IdleOneLineInputField(
            placeHolderText: "성함을 입력해주세요."
        )
        
        return textField
    }()
    
    private let ctaButton: CTAButtonType1 = {
        
        let button = CTAButtonType1(labelText: "다음")
        
        return button
    }()
    
    private let disposeBag = DisposeBag()
    
    public init(coordinator: Coordinator? = nil, viewModel: T) {
        
        self.coordinator = coordinator
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    public override func viewDidLoad() {
        
        view.backgroundColor = .white
        
        setAppearance()
        setAutoLayout()
        setRecognizer()
        setObservable()
    }
    
    private func setAppearance() {
        
        view.layoutMargins = .init(top: 32, left: 20, bottom: 0, right: 20)
    }
    
    private func setAutoLayout() {
        
        [
            processTitle,
            textField,
            ctaButton,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
        
            processTitle.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            processTitle.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            processTitle.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            textField.topAnchor.constraint(equalTo: processTitle.bottomAnchor, constant: 32),
            textField.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            textField.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            
            ctaButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            ctaButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            ctaButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        ])
    }
    
    private func setRecognizer() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setObservable() {
        
        // - CTA버튼 비활성화
        ctaButton.setEnabled(false)
        
        var input = viewModel.input
        
        input.name = textField.eventPublisher.asObservable()
        input.ctaButtonClicked = ctaButton.eventPublisher.asObservable()
        
        viewModel.transform(input: input)
            .ctaButtonEnabled?
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] in
                self?.ctaButton.setEnabled($0)
            })
            .disposed(by: disposeBag)
        
        ctaButton
            .eventPublisher
            .emit { [weak self] _ in
                
                self?.coordinator?.next()
            }
            .disposed(by: disposeBag)
    }
    
    @objc
    func tapGestureHandler() {
        
        _ = textField.resignFirstResponder()
    }
    
    public func cleanUp() {
        
    }
}
