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

// MARK: 센터주소 (도로명, 지번주소 + 상세주소)
class AddressView: UIView {
    
    // init
    
    // View
    private let processTitle: IdleLabel = {
        let label = IdleLabel(typography: .Heading2)
        label.textString = "센터 주소 정보를 입력해주세요."
        label.textAlignment = .left
        return label
    }()

    let contentView: AddressContentView
    
    // 하단 버튼
    let ctaButton: CTAButtonType1 = {
        
        let button = CTAButtonType1(labelText: "다음")
        button.setEnabled(false)
        return button
    }()
    
    // Observable
    private let disposeBag = DisposeBag()
    
    init(viewController vc: UIViewController) {
        
        self.contentView = AddressContentView(viewController: vc)
        super.init(frame: .zero)
        setAppearance()
        setLayout()
        setKeyboardAvoidance()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func setAppearance() {
        self.backgroundColor = .white
        self.layoutMargins = .init(top: 32, left: 20, bottom: 0, right: 20)
    }
    
    private func setLayout() {
        
        [
            processTitle,
            contentView,
            ctaButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            
            processTitle.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            processTitle.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            processTitle.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: processTitle.bottomAnchor, constant: 32),
            contentView.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            
            ctaButton.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            ctaButton.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            ctaButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16)
        ])
    }
    
    
    public func bind(viewModel vm: AddressInputViewModelable) {
        
        contentView.bind(viewModel: vm)
        
        // output
        vm
            .addressValidation?
            .drive(onNext: { [ctaButton] isValid in
                ctaButton.setEnabled(isValid)
            })
            .disposed(by: disposeBag)
    }
    
    public func bind(viewModel: RegisterRecruitmentPostViewModelable) {
        
        contentView.bind(viewModel: viewModel)
        
        // Output
        viewModel
            .addressInputNextable?
            .drive(onNext: { [ctaButton] isNextable in
                ctaButton.setEnabled(isNextable)
            })
            .disposed(by: disposeBag)
    }
    
    func setKeyboardAvoidance() {
        
        [
            contentView.detailAddressField
        ].forEach { (view: IdleKeyboardAvoidable) in
            
            view.setKeyboardAvoidance(movingView: self)
        }
    }
}

