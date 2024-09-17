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
    private let buttonContainer: PrevOrNextContainer = {
        let container = PrevOrNextContainer()
        container.nextButton.setEnabled(false)
        return container
    }()
    
    lazy var nextButtonClicked: Observable<Void> = buttonContainer.nextBtnClicked.asObservable()
    lazy var prevButtonClicked: Observable<Void> = buttonContainer.prevBtnClicked.asObservable()
    
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
            buttonContainer
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
            
            buttonContainer.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            buttonContainer.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            buttonContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -14)
        ])
    }
    
    
    public func bind(viewModel vm: AddressInputViewModelable) {
        
        contentView.bind(viewModel: vm)
        
        // output
        vm
            .addressValidation?
            .drive(onNext: { [buttonContainer] isValid in
                buttonContainer.nextButton.setEnabled(isValid)
            })
            .disposed(by: disposeBag)
    }
    
    public func bind(viewModel: RegisterRecruitmentPostViewModelable) {
        
        contentView.bind(viewModel: viewModel)
        
        // Output
        viewModel
            .addressInputNextable?
            .drive(onNext: { [buttonContainer] isNextable in
                buttonContainer.nextButton.setEnabled(isNextable)
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

