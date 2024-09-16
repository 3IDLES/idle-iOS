//
//  AuthBusinessOwnerViewController.swift
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

public protocol AuthBusinessOwnerInputable {
    var editingBusinessNumber: BehaviorRelay<String> { get set }
    var requestBusinessNumberValidation: PublishRelay<Void> { get set }
}

public protocol AuthBusinessOwnerOutputable {
    var canSubmitBusinessNumber: Driver<Bool>? { get set }
    var businessNumberVO: Driver<BusinessInfoVO>? { get set }
    var businessNumberValidationFailure: Driver<Void>? { get set }
}

public class AuthBusinessOwnerViewController<T: ViewModelType>: BaseViewController
where T.Input: AuthBusinessOwnerInputable & PageProcessInputable, T.Output: AuthBusinessOwnerOutputable, T: BaseViewModel {
    
    // View
    private let processTitle: ResizableUILabel = {
       
        let label = ResizableUILabel()
        
        label.text = "사업자 등록번호를 입력해주세요."
        label.font = DSKitFontFamily.Pretendard.bold.font(size: 20)
        label.textAlignment = .left
        
        return label
    }()
    
    // MARK: 사업자 등록 번호 조회
    private let businessNumberField: IFType1 = {
        
       let textField = IFType1(
        placeHolderText: "사업자 등록번호를 입력해주세요.",
        submitButtonText: "검색",
        keyboardType: .numberPad
       )
        
        textField.idleTextField.isCompleteImageAvailable = false
        
        return textField
    }()
    
    private let isThatRightLabel: ResizableUILabel = {
        
        let label = ResizableUILabel()
        label.font = DSKitFontFamily.Pretendard.semiBold.font(size: 16)
        label.text = "아래의 시설이 맞나요?"
        label.textColor = DSKitAsset.Colors.gray500.color
        label.textAlignment = .left
        
        return label
    }()
    
    private let centerInfoBox: InfoBox = {
       
        let infoBox = InfoBox(
            titleText: "",
            items: []
        )
        
        return infoBox
        
    }()
    
    private let buttonContainer = PrevOrNextContainer()
    
    public init(viewModel: T) {
        
        super.init(nibName: nil, bundle: nil)
        
        super.bind(viewModel: viewModel)
        
        setAppearance()
        setAutoLayout()
        initialUISettuing()
        setObservable()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    public override func viewDidLoad() {
        
        view.backgroundColor = .clear
    }
    
    private func setAppearance() {
        
        view.layoutMargins = .init(top: 32, left: 20, bottom: 0, right: 20)
    }
    
    private func setAutoLayout() {
        
        [
            processTitle,
            businessNumberField,
            isThatRightLabel,
            centerInfoBox,
            buttonContainer,
        ].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            processTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            processTitle.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            processTitle.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            businessNumberField.topAnchor.constraint(equalTo: processTitle.bottomAnchor, constant: 32),
            businessNumberField.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            businessNumberField.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            isThatRightLabel.topAnchor.constraint(equalTo: businessNumberField.bottomAnchor, constant: 28),
            isThatRightLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            isThatRightLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            centerInfoBox.topAnchor.constraint(equalTo: isThatRightLabel.bottomAnchor, constant: 20),
            centerInfoBox.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            centerInfoBox.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            buttonContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -14),
            buttonContainer.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            buttonContainer.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
        ])
    }
    
    private func initialUISettuing() {
        
        // Initial setting
        dismissCenterInfo()
        
        // 검색 버튼 비활성화
        businessNumberField.button.setEnabled(false)
        
        // - CTA버튼 비활성화
        buttonContainer.nextButton.setEnabled(false)
    }
    
    private func setObservable() {
        
        guard let viewModel = self.viewModel as? T else { return }
        
        // MARK: Input
        let input = viewModel.input
        
        // 현재 입력중인 정보 전송
        businessNumberField
            .idleTextField
            .textField.rx.text
            .compactMap { $0 }
            .bind(to: input.editingBusinessNumber)
            .disposed(by: disposeBag)
        
        // 인증, 확인 버튼이 눌린 경우
        businessNumberField
            .eventPublisher
            .map { _ in () }
            .bind(to: input.requestBusinessNumberValidation)
            .disposed(by: disposeBag)
        
        // 화면전환
        buttonContainer.nextBtnClicked
            .asObservable()
            .bind(to: input.nextButtonClicked)
            .disposed(by: disposeBag)
        
        buttonContainer.prevBtnClicked
            .asObservable()
            .bind(to: input.prevButtonClicked)
            .disposed(by: disposeBag)
        
        // MARK: Output
        let output = viewModel.output
        
        // 입력중인 사업자 번호가 특정 조건(ex: 입력길이)을 만족한 경우 '인증'버튼 활성화
        output
            .canSubmitBusinessNumber?
            .drive(onNext: { [weak self] isValid in
                self?.businessNumberField.button.setEnabled(isValid)
            })
            .disposed(by: disposeBag)
        
        // 사업자 번호 조회 결과
        output
            .businessNumberVO?
            .drive(onNext: { [weak self] vo in
                printIfDebug("✅ \(vo.name) 조회결과")
                self?.displayCenterInfo(vo: vo)
                self?.buttonContainer.nextButton.setEnabled(true)
            })
            .disposed(by: disposeBag)
        
        output
            .businessNumberValidationFailure?
            .drive(onNext: { [weak self] in
                // 정보가 없는 경우
                self?.dismissCenterInfo()
            })
            .disposed(by: disposeBag)
    }
    
    private func displayCenterInfo(vo: BusinessInfoVO) {
        centerInfoBox.update(
            titleText: vo.name,
            items: vo.keyValue.map { (key: $0, value: $1) }
        )
        
        isThatRightLabel.isHidden = false
        centerInfoBox.isHidden = false
    }
    
    private func dismissCenterInfo() {
        
        isThatRightLabel.isHidden = true
        centerInfoBox.isHidden = true
    }
    
    public func cleanUp() {
        
    }
}
