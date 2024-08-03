//
//  AddressInputView.swift
//  CenterFeature
//
//  Created by choijunios on 7/29/24.
//

import UIKit
import PresentationCore
import BaseFeature
import RxCocoa
import RxSwift
import Entity
import DSKit

public class AddressInputStateObject {
    
    public var addressInfo: AddressInformation?
    public var detailAddress: String = ""
    
    public init() { }
}

public protocol AddressInputViewModelableVer2 {
    
    var addressInformation: PublishRelay<AddressInformation> { get }
    var detailAddress: PublishRelay<String> { get }
    
    var addressInputStateObject: Driver<AddressInputStateObject> { get }
    var addressInputNextable: Driver<Bool> { get }
}

public protocol AddressInputViewModelable {
    
    // Input
    var editingAddress: PublishRelay<AddressInformation> { get }
    var editingDetailAddress: PublishRelay<String> { get }
    
    // Output
    var addressValidation: Driver<Bool>? { get }
}

// MARK: 센터주소 (도로명, 지번주소 + 상세주소)
class AddressView: UIView, DaumAddressSearchDelegate {
    
    // init
    public weak var viewController: UIViewController?
    
    // View
    private let processTitle: IdleLabel = {
        let label = IdleLabel(typography: .Heading2)
        label.textString = "센터 주소 정보를 입력해주세요."
        label.textAlignment = .left
        return label
    }()

    private let addressSearchButton: TextButtonType2 = {
       
        let button = TextButtonType2(labelText: "도로명 주소를 입력해주세요.")
        
        return button
    }()
    
    let detailAddressField: IFType2 = {
        let field = IFType2(
            titleLabelText: "상세 주소",
            placeHolderText: "상세 주소를 입력해주세요. (예: 2층 204호)"
        )
        return field
    }()
    
    // 하단 버튼
    let ctaButton: CTAButtonType1 = {
        
        let button = CTAButtonType1(labelText: "다음")
        button.setEnabled(false)
        return button
    }()
    
    // Observable
    private let addressPublisher: PublishRelay<AddressInformation> = .init()
    private let disposeBag = DisposeBag()
    
    init(viewController vc: UIViewController) {
        self.viewController = vc
        super.init(frame: .zero)
        setAppearance()
        setLayout()
        setObservable()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func setAppearance() {
        self.backgroundColor = .white
        self.layoutMargins = .init(top: 32, left: 20, bottom: 0, right: 20)
    }
    
    private func setLayout() {
        
        let roadAddressStack = VStack(
            [
                {
                    let label = IdleLabel(typography: .Subtitle4)
                    label.textString = "도로명주소"
                    label.textAlignment = .left
                    return label
                }(),
                addressSearchButton,
            ],
            spacing: 6,
            alignment: .fill
        )
        
        let inputStack = VStack(
            [
                roadAddressStack,
                detailAddressField
            ],
            spacing: 28,
            alignment: .fill
        )
        
        [
            processTitle,
            inputStack,
            ctaButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            
            processTitle.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            processTitle.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            processTitle.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            
            inputStack.topAnchor.constraint(equalTo: processTitle.bottomAnchor, constant: 32),
            inputStack.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            inputStack.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            
            ctaButton.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            ctaButton.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            ctaButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16)
        ])
    }
    
    private func setObservable() {
        
        addressSearchButton
            .eventPublisher
            .subscribe { [weak self] _ in
                self?.showDaumSearchView()
            }
            .disposed(by: disposeBag)
        
        addressPublisher
            .subscribe(onNext: { [addressSearchButton] info in
                
                if !info.roadAddress.isEmpty {
                    
                    addressSearchButton.label.textString = info.roadAddress
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func showDaumSearchView() {
        let vc = DaumAddressSearchViewController()
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    public func bind(viewModel vm: AddressInputViewModelable) {
        
        // Input
        addressPublisher
            .bind(to: vm.editingAddress)
            .disposed(by: disposeBag)
        
        detailAddressField
            .uITextField.rx.text
            .compactMap { $0 }
            .bind(to: vm.editingDetailAddress)
            .disposed(by: disposeBag)
        
        // output
        vm
            .addressValidation?
            .drive(onNext: { [ctaButton] isValid in
                ctaButton.setEnabled(isValid)
            })
            .disposed(by: disposeBag)
    }
    
    public func bind(viewModel: RegisterRecruitmentPostViewModelable) {
        
        // Input
        addressPublisher
            .bind(to: viewModel.addressInformation)
            .disposed(by: disposeBag)
        
        detailAddressField
            .uITextField.rx.text
            .compactMap { $0 }
            .bind(to: viewModel.detailAddress)
            .disposed(by: disposeBag)
        
        // Output
        viewModel
            .addressInputNextable
            .drive(onNext: { [ctaButton] isNextable in
                ctaButton.setEnabled(isNextable)
            })
            .disposed(by: disposeBag)
        
        // 초기값 설정
        viewModel
            .addressInputStateObject
            .drive(onNext: { [addressSearchButton, detailAddressField] state in
                
                if let info = state.addressInfo {
                    addressSearchButton.label.textString = info.roadAddress
                }
                 
                if !state.detailAddress.isEmpty {
                    detailAddressField.uITextField.text = state.detailAddress
                }
            })
            .disposed(by: disposeBag)
    }
    
    public func addressSearch(addressData: [AddressDataKey : String]) {
        
//            let address = addressData[.address] ?? "알 수 없는 주소"
        let jibunAddress = addressData[.jibunAddress] ?? "알 수 없는 지번 주소"
        let roadAddress = addressData[.roadAddress] ?? "알 수 없는 도로명 주소"
        
        addressPublisher.accept(
            AddressInformation(
                roadAddress: roadAddress,
                jibunAddress: jibunAddress
            )
        )
    }
}
