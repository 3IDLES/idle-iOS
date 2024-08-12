//
//  CustomerInformationView.swift
//  CenterFeature
//
//  Created by choijunios on 7/31/24.
//

import UIKit
import BaseFeature
import PresentationCore
import RxCocoa
import RxSwift
import Entity
import DSKit
 

public class CustomerInformationView: UIView, RegisterRecruitmentPostViews {
    
    // Init
        
    // Not init
    
    // View
    private let processTitle: IdleLabel = {
        let label = IdleLabel(typography: .Heading2)
        label.textString = "고객 정보를 입력해주세요."
        label.textAlignment = .left
        return label
    }()
    
    let contentView = CustomerInformationContentView()
    
    let ctaButton: CTAButtonType1 = {
        
        let button = CTAButtonType1(labelText: "다음")
        button.setEnabled(false)
        return button
    }()
    
    private let disposeBag = DisposeBag()
    
    public init() {
        
        super.init(frame: .zero)
        
        setAppearance()
        setLayout()
        setObservable()
        setKeyboardAvoidance()
    }
    public required init?(coder: NSCoder) { fatalError() }
    
    private func setAppearance() {
        self.backgroundColor = .white
        self.layoutMargins = .init(top: 32, left: 20, bottom: 0, right: 20)
    }
    
    private func setLayout() {
        
        let scrollView = UIScrollView()
        scrollView.contentInset = .init(
            top: 0,
            left: 20,
            bottom: 24,
            right: 20
        )
        
        scrollView.delaysContentTouches = false
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        let horizontalInset = scrollView.contentInset.left + scrollView.contentInset.right
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -horizontalInset)
        ])
        
        [
            processTitle,
            
            scrollView,
            
            ctaButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            
            processTitle.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            processTitle.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            processTitle.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            
            scrollView.topAnchor.constraint(equalTo: processTitle.bottomAnchor, constant: 32),
            scrollView.leftAnchor.constraint(equalTo: self.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: self.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: ctaButton.topAnchor),
            
            ctaButton.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            ctaButton.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            ctaButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16)
        ])
    }

    
    private func setObservable() { }
    
    public func bind(viewModel: RegisterRecruitmentPostViewModelable) {
      
        // Input
        contentView.bind(viewModel: viewModel)
        
        // Output
        viewModel
            .customerInformationNextable
            .drive(onNext: { [ctaButton] nextable in
                ctaButton.setEnabled(nextable)
            })
            .disposed(by: disposeBag)
    }
    
    func setKeyboardAvoidance() {
        
        [
            contentView.nameField,
            contentView.birthYearField,
            contentView.weightField,
            contentView.deceaseField,
        ].forEach { (view: IdleKeyboardAvoidable) in
            
            view.setKeyboardAvoidance(movingView: contentView)
        }
    }
}
