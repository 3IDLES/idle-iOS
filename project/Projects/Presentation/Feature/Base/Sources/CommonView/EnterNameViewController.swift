//
//  EnterNameViewController.swift
//  BaseFeature
//
//  Created by choijunios on 6/30/24.
//

import UIKit
import DSKit
import RxSwift
import RxCocoa
import PresentationCore

public protocol EnterNameInputable {
    var editingName: PublishRelay<String> { get }
}

public protocol EnterNameOutputable {
    var nameValidation: Driver<Bool>? { get set }
}

public class EnterNameViewController<T: ViewModelType>: DisposableViewController
where T.Input: EnterNameInputable & PageProcessInputable, T.Output: EnterNameOutputable {
    
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
    
    public init(viewModel: T) {
        
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        setAppearance()
        setAutoLayout()
        setRecognizer()
        initialUISettuing()
        setObservable()
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    public override func viewDidLoad() {
        
        view.backgroundColor = .clear
    }
    
    private func setAppearance() { }
    
    private func setAutoLayout() {
        
        view.layoutMargins = .init(top: 28, left: 20, bottom: 0, right: 20)
        
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
            
            ctaButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            ctaButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            ctaButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        ])
    }
    
    private func setRecognizer() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func initialUISettuing() {
        
        // - CTA버튼 비활성화
        ctaButton.setEnabled(false)
    }
    
    private func setObservable() {
        
        // - CTA버튼 비활성화
        ctaButton.setEnabled(false)
        
        // MARK: Input
        let input = viewModel.input
        
        textField
            .textField.rx.text
            .compactMap { $0 }
            .bind(to: input.editingName)
            .disposed(by: disposeBag)
            
        
        // MARK: Output
        let output = viewModel.output
        
        output
            .nameValidation?
            .drive(onNext: { [weak self] isValid in
                self?.ctaButton.setEnabled(isValid)
            })
            .disposed(by: disposeBag)
        
        // MARK: ViewController한정 로직
        // CTA버튼 클릭시 화면전환
        ctaButton
            .eventPublisher
            .bind(to: input.nextButtonClicked)
            .disposed(by: disposeBag)
    }
    
    @objc
    func tapGestureHandler() {
        
        _ = textField.resignFirstResponder()
    }
    
    public func cleanUp() {
        
    }
}
