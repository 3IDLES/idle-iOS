//
//  AddressInputView.swift
//  BaseFeature
//
//  Created by choijunios on 7/29/24.
//

import UIKit
import PresentationCore
import Domain
import DSKit


import RxCocoa
import RxSwift

// MARK: 센터주소 (도로명, 지번주소 + 상세주소)
public class AddressView: UIView {
    
    // init
    
    // View
    public let processTitle: IdleLabel = {
        let label = IdleLabel(typography: .Heading2)
        label.textString = "센터 주소 정보를 입력해주세요."
        label.textAlignment = .left
        return label
    }()

    public let contentView: AddressContentView
    
    // 하단 버튼
    public let buttonContainer: PrevOrNextContainer = {
        let container = PrevOrNextContainer()
        container.nextButton.setEnabled(false)
        return container
    }()
    
    public lazy var nextButtonClicked: Observable<Void> = buttonContainer.nextBtnClicked.asObservable()
    public lazy var prevButtonClicked: Observable<Void> = buttonContainer.prevBtnClicked.asObservable()
    
    // Observable
    public let disposeBag = DisposeBag()
    
    public init(viewController vc: UIViewController) {
        
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
    
    func setKeyboardAvoidance() {
        
        [
            contentView.detailAddressField
        ].forEach { (view: IdleKeyboardAvoidable) in
            
            view.setKeyboardAvoidance(movingView: self)
        }
    }
}

