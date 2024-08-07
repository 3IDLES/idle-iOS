//
//  AddressContentView.swift
//  BaseFeature
//
//  Created by choijunios on 8/7/24.
//

import UIKit
import PresentationCore
import RxCocoa
import RxSwift
import Entity
import DSKit

/// 공고등록에 사용됩니다.
public protocol AddressInputViewContentVMable {
    
    var addressInformation: PublishRelay<AddressInformation> { get }
    var detailAddress: PublishRelay<String> { get }
    
    var casting_addressInput: Driver<AddressInputStateObject> { get }
    var addressInputNextable: Driver<Bool> { get }
}

/// 로그인, 회원가입에 사용되는 구버전 입니다.
public protocol AddressInputViewModelable {
    
    // Input
    var editingAddress: PublishRelay<AddressInformation> { get }
    var editingDetailAddress: PublishRelay<String> { get }
    
    // Output
    var addressValidation: Driver<Bool>? { get }
}

public class AddressContentView: VStack, DaumAddressSearchDelegate {
    
    // Init
    public weak var viewController: UIViewController?
    
    // View
    private let addressSearchButton: TextButtonType2 = {
       
        let button = TextButtonType2(labelText: "도로명 주소를 입력해주세요.")
        
        return button
    }()
    
    public lazy var detailAddressField: IFType2 = {
        let field = IFType2(
            titleLabelText: "상세 주소",
            placeHolderText: "상세 주소를 입력해주세요. (예: 2층 204호)"
        )
        return field
    }()
    
    let disposeBag = DisposeBag()
    private let addressPublisher: PublishRelay<AddressInformation> = .init()
    
    public init(viewController: UIViewController) {
        self.viewController = viewController
        
        super.init([], spacing: 28,
                   alignment: .fill)
        
        setLayout()
        setObservable()
    }
    
    required init(coder: NSCoder) { fatalError() }
    
    func setLayout() {
        
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
        
        [
            roadAddressStack,
            detailAddressField
        ].forEach {
            self.addArrangedSubview($0)
        }
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
    }
    
    public func bind(viewModel: AddressInputViewContentVMable) {
        
        // 초기값 설정
        viewModel
            .casting_addressInput
            .drive(onNext: { [addressSearchButton, detailAddressField] state in
                
                if let info = state.addressInfo {
                    addressSearchButton.label.textString = info.roadAddress
                }
                
                if !state.detailAddress.isEmpty {
                    detailAddressField.uITextField.text = state.detailAddress
                }
            })
            .disposed(by: disposeBag)
        
        // Input
        addressPublisher
            .bind(to: viewModel.addressInformation)
            .disposed(by: disposeBag)
        
        detailAddressField
            .uITextField.rx.text
            .compactMap { $0 }
            .bind(to: viewModel.detailAddress)
            .disposed(by: disposeBag)
    }
    
    
    private func showDaumSearchView() {
        let vc = DaumAddressSearchViewController()
        vc.delegate = self
        viewController?.navigationController?.pushViewController(vc, animated: true)
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
