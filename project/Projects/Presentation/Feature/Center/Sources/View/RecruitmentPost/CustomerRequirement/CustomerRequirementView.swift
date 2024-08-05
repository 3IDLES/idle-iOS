//
//  CustomerRequirementView.swift
//  CenterFeature
//
//  Created by choijunios on 7/30/24.
//

import UIKit
import BaseFeature
import PresentationCore
import RxCocoa
import RxSwift
import Entity
import DSKit

public protocol CustomerRequirementViewModelable {
    var mealSupportNeeded: PublishRelay<Bool> { get }
    var toiletSupportNeeded: PublishRelay<Bool> { get }
    var movingSupportNeeded: PublishRelay<Bool> { get }
    var dailySupportTypes: PublishRelay<(DailySupportType, Bool)> { get }
    var additionalRequirement: PublishRelay<String> { get }
    
    var customerRequirementStateObject: Driver<CustomerRequirementStateObject> { get }
    var customerRequirementNextable: Driver<Bool> { get }
}

public class CustomerRequirementView: UIView, RegisterRecruitmentPostViews {
        
    // Not init
    
    // View
    private let processTitle: IdleLabel = {
        let label = IdleLabel(typography: .Heading2)
        label.textString = "고객 요구사항을 입력해주세요."
        label.textAlignment = .left
        return label
    }()
    
    let contentView = CustomerRequirementContentView()
    
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
            .customerRequirementNextable
            .drive(onNext: { [ctaButton] nextable in
                ctaButton.setEnabled(nextable)
            })
            .disposed(by: disposeBag)
    }
    
    func setKeyboardAvoidance() {
        
        [
            contentView.additionalRequirmentField
        ].forEach { (view: IdleKeyboardAvoidable) in
            
            view.setKeyboardAvoidance(movingView: self)
        }
    }
}


class CustomerRequirementContentView: UIView {
    
    // 식사 보조 선택
    let mealSupportBtn1: StateButtonTyp1 = {
        let btn = StateButtonTyp1(text: "필요", initial: .normal)
        btn.label.typography = .Body3
        return btn
    }()
    let mealSupportBtn2: StateButtonTyp1 = {
        let btn = StateButtonTyp1(text: "불필요", initial: .normal)
        btn.label.typography = .Body3
        return btn
    }()
    
    
    // 배변 보조 선택
    let toiletSupportBtn1: StateButtonTyp1 = {
        let btn = StateButtonTyp1(text: "필요", initial: .normal)
        btn.label.typography = .Body3
        return btn
    }()
    let toiletSupportBtn2: StateButtonTyp1 = {
        let btn = StateButtonTyp1(text: "불필요", initial: .normal)
        btn.label.typography = .Body3
        return btn
    }()
    
    
    // 이동 보조 선택
    let movingSupportBtn1: StateButtonTyp1 = {
        let btn = StateButtonTyp1(text: "필요", initial: .normal)
        btn.label.typography = .Body3
        return btn
    }()
    let movingSupportBtn2: StateButtonTyp1 = {
        let btn = StateButtonTyp1(text: "불필요", initial: .normal)
        btn.label.typography = .Body3
        return btn
    }()
    
    // 일상 보조 선택
    let dailySupport_cleaning: StateButtonTyp1 = {
        let btn = StateButtonTyp1(text: "청소", initial: .normal)
        btn.label.typography = .Body3
        return btn
    }()
    let dailySupport_laundary: StateButtonTyp1 = {
        let btn = StateButtonTyp1(text: "빨래", initial: .normal)
        btn.label.typography = .Body3
        return btn
    }()
    let dailySupport_walking: StateButtonTyp1 = {
        let btn = StateButtonTyp1(text: "산책", initial: .normal)
        btn.label.typography = .Body3
        return btn
    }()
    let dailySupport_exercise: StateButtonTyp1 = {
        let btn = StateButtonTyp1(text: "운동보조", initial: .normal)
        btn.label.typography = .Body3
        return btn
    }()
    let dailySupport_listener: StateButtonTyp1 = {
        let btn = StateButtonTyp1(text: "말벗", initial: .normal)
        btn.label.typography = .Body3
        return btn
    }()
    
    lazy var dailySupportViews: [DailySupportType: StateButtonTyp1] = [
        .cleaning: dailySupport_cleaning,
        .laundry: dailySupport_laundary,
        .walking: dailySupport_walking,
        .exerciseSupport: dailySupport_exercise,
        .listener: dailySupport_listener
    ]
    
    // 추가 요구사항
    lazy var additionalRequirmentField: MultiLineTextField = {
        let field = MultiLineTextField(
            typography: .Body3,
            placeholderText: "추가적으로 요구사항이 있다면 작성해주세요."
        )
        field.setKeyboardAvoidance(movingView: self)
        return field
    }()
    
    
    private let disposeBag = DisposeBag()
    
    public init() {
        super.init(frame: .zero)
        setLayout()
    }
    
    public required init(coder: NSCoder) { fatalError() }
    
    
    func setLayout() {
        
        // 정적인 사이즈 설정
        [
            mealSupportBtn1,
            mealSupportBtn2,
            toiletSupportBtn1,
            toiletSupportBtn2,
            movingSupportBtn1,
            movingSupportBtn2,
            dailySupport_cleaning,
            dailySupport_laundary,
            dailySupport_walking,
            dailySupport_exercise,
            dailySupport_listener,
        ].forEach { buttton in
            buttton.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                buttton.widthAnchor.constraint(equalToConstant: 104),
                buttton.heightAnchor.constraint(equalToConstant: 44),
            ])
        }
        
        NSLayoutConstraint.activate([
            additionalRequirmentField.heightAnchor.constraint(equalToConstant: 156)
        ])
        
        // 스크롤뷰에 들어갈 뷰 레아이웃 설정
        let stackList: [VStack] = [
        
            VStack(
                [
                    IdleContentTitleLabel(titleText: "식사보조"),
                    HStack([mealSupportBtn1, mealSupportBtn2, UIView()], spacing: 4),
                ],
                spacing: 6,
                alignment: .fill
            ),
            
            VStack(
                [
                    IdleContentTitleLabel(titleText: "배변보조"),
                    HStack([toiletSupportBtn1, toiletSupportBtn2, UIView()], spacing: 4),
                ],
                spacing: 6,
                alignment: .fill
            ),
            
            VStack(
                [
                    IdleContentTitleLabel(titleText: "이동보조"),
                    HStack([movingSupportBtn1, movingSupportBtn2, UIView()], spacing: 4),
                ],
                spacing: 6,
                alignment: .fill
            ),
            
            VStack(
                [
                    IdleContentTitleLabel(titleText: "일상보조", subTitleText: "(선택, 다중 선택 가능)"),
                    VStack(
                        [
                            HStack([dailySupport_cleaning, dailySupport_laundary, dailySupport_walking, UIView()], spacing: 4),
                            HStack([dailySupport_exercise, dailySupport_listener, UIView()], spacing: 4)
                        ],
                        spacing: 4,
                        alignment: .fill
                    )
                ],
                spacing: 6,
                alignment: .fill
            ),
            
            VStack(
                [
                    IdleContentTitleLabel(titleText: "이외에도 요구사항이 있다면 적어주세요.", subTitleText: "(선택)"),
                    additionalRequirmentField
                ],
                spacing: 6,
                alignment: .fill
            ),
        ]
        
        let scrollViewContentStack = VStack(
            stackList,
            spacing: 28,
            alignment: .fill
        )
        
        [
            scrollViewContentStack
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            scrollViewContentStack.topAnchor.constraint(equalTo: self.topAnchor),
            scrollViewContentStack.leftAnchor.constraint(equalTo: self.leftAnchor),
            scrollViewContentStack.rightAnchor.constraint(equalTo: self.rightAnchor),
            scrollViewContentStack.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
            
    public func bind(viewModel: RegisterRecruitmentPostViewModelable) {
                
        // Input
        Observable
            .merge(
                mealSupportBtn1.eventPublisher.compactMap { state -> Bool? in state == .accent ? true : nil },
                mealSupportBtn2.eventPublisher.compactMap { state -> Bool? in state == .accent ? false : nil }
            ).map { [mealSupportBtn1, mealSupportBtn2] isActive in
                
                if isActive {
                    mealSupportBtn2.setState(.normal)
                } else {
                    mealSupportBtn1.setState(.normal)
                }
                
                return isActive
            }
            .bind(to: viewModel.mealSupportNeeded)
            .disposed(by: disposeBag)
        
        Observable
            .merge(
                toiletSupportBtn1.eventPublisher.compactMap { state -> Bool? in state == .accent ? true : nil },
                toiletSupportBtn2.eventPublisher.compactMap { state -> Bool? in state == .accent ? false : nil }
            ).map { [toiletSupportBtn1, toiletSupportBtn2] isActive in
                
                if isActive {
                    toiletSupportBtn2.setState(.normal)
                } else {
                    toiletSupportBtn1.setState(.normal)
                }
                
                return isActive
            }
            .bind(to: viewModel.toiletSupportNeeded)
            .disposed(by: disposeBag)
        
        Observable
                .merge(
                    movingSupportBtn1.eventPublisher.compactMap { state -> Bool? in state == .accent ? true : nil },
                    movingSupportBtn2.eventPublisher.compactMap { state -> Bool? in state == .accent ? false : nil }
                )
                .map { [movingSupportBtn1, movingSupportBtn2] isActive in
                    
                    DispatchQueue.main.async {
                        if isActive {
                            movingSupportBtn2.setState(.normal)
                        } else {
                            movingSupportBtn1.setState(.normal)
                        }
                    }
                    
                    return isActive
                }
                .bind(to: viewModel.movingSupportNeeded)
                .disposed(by: disposeBag)
        
        for (supportType, supportView) in dailySupportViews {
            
            supportView
                .eventPublisher
                .map { state in
                    (supportType, state == .accent)
                }
                .bind(to: viewModel.dailySupportTypes)
                .disposed(by: disposeBag)
        }
        
        additionalRequirmentField
            .rx.text
            .compactMap { $0 }
            .bind(to: viewModel.additionalRequirement)
            .disposed(by: disposeBag)
        
        // Output, viewModel로 부터 전달받는 상태
        viewModel
            .customerRequirementStateObject
            .drive(onNext: { [weak self] stateFromVM in
                
                guard let self else { return }
                
                
                // 식사보조
                if let isEnabled = stateFromVM.mealSupportNeeded {
                    mealSupportBtn1.setState(isEnabled ? .accent : .normal)
                    mealSupportBtn2.setState(!isEnabled ? .accent : .normal)
                }
                
                
                // 배변보조
                if let isEnabled = stateFromVM.toiletSupportNeeded {
                    toiletSupportBtn1.setState(isEnabled ? .accent : .normal)
                    toiletSupportBtn2.setState(!isEnabled ? .accent : .normal)
                }
                
                
                // 이동보조
                if let isEnabled = stateFromVM.movingSupportNeeded {
                    movingSupportBtn1.setState(isEnabled ? .accent : .normal)
                    movingSupportBtn2.setState(!isEnabled ? .accent : .normal)
                }
                
                
                // 일상보조
                for (supportType, isActive) in stateFromVM.dailySupportTypeNeeds {
                    dailySupportViews[supportType]?.setState(isActive ? .accent : .normal)
                }
                    
                
                // 추가요구사항
                let additionalRequirementText = stateFromVM.additionalRequirement
                if !additionalRequirementText.isEmpty {
                    additionalRequirmentField.textString = additionalRequirementText
                }
                
            })
            .disposed(by: disposeBag)
    }
}
