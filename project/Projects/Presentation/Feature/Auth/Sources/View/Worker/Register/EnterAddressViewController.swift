//
//  EnterAddressViewController.swift
//  AuthFeature
//
//  Created by choijunios on 7/15/24.
//

import UIKit
import RxSwift
import RxCocoa
import DSKit
import Entity
import PresentationCore
import BaseFeature

public protocol EnterAddressInputable {
    var addressInformation: PublishRelay<AddressInformation> { get }
}

public class EnterAddressViewController<T: ViewModelType>: BaseViewController
where T.Input: EnterAddressInputable & CTAButtonEnableInputable, T.Output: RegisterValidationOutputable {
    
    public var coordinator: WorkerRegisterCoordinator?
    
    private let viewModel: T
    
    // View
    private let processTitle1: IdleLabel = {
        let label = IdleLabel(typography: .Heading2)
        
        label.textString = "현재 거주 중인 곳의"
        
        return label
    }()
    private let processTitle2: IdleLabel = {
        let label = IdleLabel(typography: .Heading2)
        
        label.textString = "주소를 입력해주세요."
        
        return label
    }()
    
    private let addressSearchLabel: IdleLabel = {
        
        let label = IdleLabel(typography: .Subtitle4)
        label.textString = "우편번호"
        label.textAlignment = .left
        
        return label
    }()
    private let addressSearchButton: TextButtonType2 = {
       
        let button = TextButtonType2(labelText: "우편번호 찾으로가기")
        
        return button
    }()
    
//    private let detailAddressLabel: IdleLabel = {
//        
//        let label = IdleLabel(typography: .Subtitle4)
//        label.textString = "상세주소"
//        label.textAlignment = .left
//        
//        return label
//    }()
//    private let detailAddressTextField: IdleOneLineInputField = {
//        
//        let textField = IdleOneLineInputField(
//            placeHolderText: "상세 주소를 입력해주세요. (예: 101동 101호)"
//        )
//        
//        return textField
//    }()
    
    private let ctaButton: CTAButtonType1 = {
        
        let button = CTAButtonType1(labelText: "완료")
        
        return button
    }()
    
    let disposeBag = DisposeBag()
    
    public init(coordinator: WorkerRegisterCoordinator? = nil, viewModel: T) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        setAppearance()
        setAutoLayout()
        setObservable()
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    private func setAppearance() {
        self.view.backgroundColor = .white
        view.layoutMargins = .init(top: 32, left: 20, bottom: 0, right: 20)
    }
    
    private func setAutoLayout() {
        
        let stack1 = VStack(
            [
                processTitle1,
                processTitle2,
            ],
            alignment: .leading)
        
        let stack2 = VStack(
            [
                addressSearchLabel,
                addressSearchButton,
            ],
            spacing: 6,
            alignment: .fill)
        
//        let stack3 = VStack(
//            [
//                detailAddressLabel,
//                detailAddressTextField
//            ],
//            spacing: 6,
//            alignment: .fill)
        
        [
            stack1,
            stack2,
//            stack3,
            ctaButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            
            stack1.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            stack1.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            
            stack2.topAnchor.constraint(equalTo: stack1.bottomAnchor, constant: 32),
            stack2.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stack2.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        
//            stack3.topAnchor.constraint(equalTo: stack2.bottomAnchor, constant: 28),
//            stack3.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
//            stack3.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            ctaButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            ctaButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            ctaButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        ])
    }
    
    private let addressPublisher: PublishRelay<AddressInformation?> = .init()
    
    private func setObservable() {
        
        ctaButton.setEnabled(false)
        
        let input = viewModel.input
        
        addressPublisher
            .compactMap { $0 }
            .map({ [weak self] info in
                self?.ctaButton.setEnabled(true)
                return info
            })
            .bind(to: input.addressInformation)
            .disposed(by: disposeBag)
        
//        detailAddressTextField.textField.rx.attributedText
//            .map { $0?.string }
//            .bind(to: input.editingDetailAddress)
//            .disposed(by: disposeBag)
        
        addressSearchButton
            .eventPublisher
            .subscribe { [weak self] _ in
                self?.showDaumSearchView()
            }
            .disposed(by: disposeBag)
        
        ctaButton
            .eventPublisher
            .map({ [weak self] _ in
                self?.ctaButton.setEnabled(false)
                return ()
            })
            .bind(to: input.ctaButtonClicked)
            .disposed(by: disposeBag)
        
        let output = viewModel.output
        
        output
            .registerValidation?
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.next()
            })
            .disposed(by: disposeBag)
        
        output
            .alert?
            .drive(onNext: { [weak self] vo in
                self?.showAlert(vo: vo)
            })
            .disposed(by: disposeBag)
    }
    
    private func showDaumSearchView() {
        
        let vc = DaumAddressSearchViewController()
        vc.deleage = self
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension EnterAddressViewController: DaumAddressSearchDelegate {
    
    public func addressSearch(addressData: [AddressDataKey : String]) {
        
        let address = addressData[.address] ?? "알 수 없는 주소"
        
        let jibunAddress = addressData[.jibunAddress] ?? "알 수 없는 지번 주소"
        let roadAddress = addressData[.roadAddress] ?? "알 수 없는 도로명 주소"
        
        addressSearchButton.label.textString = address
        
        addressPublisher
            .accept(
                AddressInformation(
                    roadAddress: roadAddress,
                    jibunAddress: jibunAddress
                )
            )
    }
}
