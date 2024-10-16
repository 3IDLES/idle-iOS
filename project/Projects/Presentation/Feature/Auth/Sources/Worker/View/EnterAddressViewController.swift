//
//  EnterAddressViewController.swift
//  AuthFeature
//
//  Created by choijunios on 7/15/24.
//

import UIKit
import DSKit
import Domain
import PresentationCore
import BaseFeature


import RxSwift
import RxCocoa

public protocol EnterAddressInputable {
    var addressInformation: PublishRelay<AddressInformation> { get }
}

public class EnterAddressViewController<T: ViewModelType>: BaseViewController
where T.Input: EnterAddressInputable & PageProcessInputable, T: BaseViewModel {
    
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
    
    private let buttonContainer: PrevOrNextContainer = {
        let container = PrevOrNextContainer()
        container.nextButton.label.textString = "완료"
        container.nextButton.setEnabled(false)
        return container
    }()
    
    public init(viewModel: T) {
       
        super.init(nibName: nil, bundle: nil)
        
        super.bind(viewModel: viewModel)
        
        setAppearance()
        setAutoLayout()
        setObservable()
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    private func setAppearance() {
        self.view.backgroundColor = .white
    }
    
    private func setAutoLayout() {
        
        view.layoutMargins = .init(top: 28, left: 20, bottom: 0, right: 20)
        
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
        
        [
            stack1,
            stack2,
            buttonContainer
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
        
            buttonContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -14),
            buttonContainer.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            buttonContainer.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
        ])
    }
    
    private let addressPublisher: PublishRelay<AddressInformation?> = .init()
    
    private func setObservable() {
        
        guard let viewModel = self.viewModel as? T else { return }
        
        let input = viewModel.input
        
        addressPublisher
            .compactMap { $0 }
            .map({ [weak self] info in
                self?.buttonContainer.nextButton.setEnabled(true)
                return info
            })
            .bind(to: input.addressInformation)
            .disposed(by: disposeBag)
        
        addressSearchButton
            .eventPublisher
            .subscribe { [weak self] _ in
                self?.showDaumSearchView()
            }
            .disposed(by: disposeBag)
        
        buttonContainer.nextBtnClicked
            .asObservable()
            .bind(to: input.completeButtonClicked)
            .disposed(by: disposeBag)
        
        buttonContainer.prevBtnClicked
            .asObservable()
            .bind(to: input.prevButtonClicked)
            .disposed(by: disposeBag)
    }
    
    private func showDaumSearchView() {
        let vc = DaumAddressSearchViewController()
        vc.delegate = self
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
        addressSearchButton.label.attrTextColor = DSColor.gray900.color
        
        addressPublisher
            .accept(
                AddressInformation(
                    roadAddress: roadAddress,
                    jibunAddress: jibunAddress
                )
            )
    }
}
