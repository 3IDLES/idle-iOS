//
//  SelectGenderViewController.swift
//  AuthFeature
//
//  Created by choijunios on 6/30/24.
//

import UIKit
import DSKit
import Domain
import PresentationCore
import BaseFeature


import RxSwift
import RxCocoa

protocol SelectGenderInputable {
    var selectingGender: BehaviorRelay<Gender> { get }
}

protocol SelectGenderOutputable {
    var genderIsSelected: Driver<Bool>? { get set }
}

class SelectGenderViewController<T: ViewModelType>: BaseViewController
where T.Input: SelectGenderInputable & PageProcessInputable,
      T.Output: SelectGenderOutputable, T: BaseViewModel
{
    
    // View
    private let processTitle: IdleLabel = {
        let label = IdleLabel(typography: .Heading2)
        
        label.textString = "본인의 성별을 선택해주세요."
        
        return label
    }()
    
    private let genderButtonStack: UIStackView = {
       
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let femaleButton: StateButtonTyp1 = {
        let btn = StateButtonTyp1(
            text: "여성",
            initial: .normal
        )
        return btn
    }()
    
    private let maleButton: StateButtonTyp1 = {
        let btn = StateButtonTyp1(
            text: "남성",
            initial: .normal
        )
        return btn
    }()
    
    private let ctaButton: CTAButtonType1 = {
        
        let button = CTAButtonType1(labelText: "다음")
        button.setEnabled(false)
        return button
    }()
    
    public init(viewModel: T) {
        super.init(nibName: nil, bundle: nil)
        
        super.bind(viewModel: viewModel)
        
        setAppearance()
        setAutoLayout()
        setObservable()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    
    func setAppearance() {
        self.view.backgroundColor = .white
        view.layoutMargins = .init(top: 32, left: 20, bottom: 0, right: 20)
    }
    
    private func setAutoLayout() {
        
        [
            femaleButton,
            maleButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            genderButtonStack.addArrangedSubview($0)
        }
        
        [
            processTitle,
            genderButtonStack,
            ctaButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            
            processTitle.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            processTitle.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            processTitle.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            genderButtonStack.heightAnchor.constraint(equalToConstant: 56),
            genderButtonStack.topAnchor.constraint(equalTo: processTitle.bottomAnchor, constant: 32),
            genderButtonStack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            genderButtonStack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            ctaButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            ctaButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            ctaButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        ])
    }
    
    private func setObservable() {
        
        guard let viewModel = self.viewModel as? T else { return }
        
        let femaleClicked = femaleButton.eventPublisher
            .filter({ $0 == .accent })
            .map { [weak self] _ in
            self?.maleButton.setState(.normal, withAnimation: false)
            return Gender.female
        }
        
        let maleClicked = maleButton.eventPublisher
            .filter({ $0 == .accent })
            .map { [weak self] _ in
            self?.femaleButton.setState(.normal, withAnimation: false)
            return Gender.male
        }
        
        Observable
            .merge(femaleClicked, maleClicked)
            .bind(to: viewModel.input.selectingGender)
            .disposed(by: disposeBag)
        
        let output = viewModel.output
        
        output
            .genderIsSelected?
            .drive(onNext: { [weak self] _ in
                self?.ctaButton.setEnabled(true)
            })
            .disposed(by: disposeBag)
        
        
        // MARK: ViewController한정 로직
        // CTA버튼 클릭시 화면전환
        ctaButton
            .eventPublisher
            .bind(to: viewModel.input.nextButtonClicked)
            .disposed(by: disposeBag)
    }
}
