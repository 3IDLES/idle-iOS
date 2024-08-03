//
//  WorkTimeAndPayView.swift
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
 
public protocol WorkTimeAndPayViewModelable {
    var selectedDay: PublishRelay<(WorkDay, Bool)> { get }
    var workStartTime: PublishRelay<String> { get }
    var workEndTime: PublishRelay<String> { get }
    var paymentType: PublishRelay<PaymentType> { get }
    var paymentAmount: PublishRelay<String> { get }
    
    var workTimeAndPayStateObject: Driver<WorkTimeAndPayStateObject> { get }
    var workTimeAndPayNextable: Driver<Bool> { get }
}

public class WorkTimeAndPayView: UIView, RegisterRecruitmentPostViews {
    
    // Init
    
    // Not init
    
    
    // View
    private let processTitle: IdleLabel = {
        let label = IdleLabel(typography: .Heading2)
        label.textString = "근무 시간 및 급여를 입력해주세요."
        label.textAlignment = .left
        return label
    }()
    
    // 근무 요일
    let workDayButtons: [StateButtonTyp1] = {
        WorkDay.allCases.map { day in
            StateButtonTyp1(
                text: day.korOneLetterText,
                initial: .normal
            )
        }
    }()
    
    // 근무 시간
    let workStartTimePicker: WorkTimePicker = {
        let picker = WorkTimePicker(placeholderText: "시작 시간")
        return picker
    }()
    let workEndTimePicker: WorkTimePicker = {
        let picker = WorkTimePicker(placeholderText: "종료 시간")
        return picker
    }()
    
    // 급여 타입
    let paymentTypeButtons: [StateButtonTyp1] = {
        PaymentType.allCases.map { type in
            StateButtonTyp1(
                text: type.korLetterText,
                initial: .normal
            )
        }
    }()
    
    // 급여
    lazy var paymentField: TextFieldWithDegree = {
        let field = TextFieldWithDegree(
            degreeText: "원",
            initialText: ""
        )
        field.setKeyboardAvoidance(movingView: self)
        field.textField.keyboardType = .numberPad
        return field
    }()
    
    
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
    }
    public required init?(coder: NSCoder) { fatalError() }
    
    private func setAppearance() {
        self.backgroundColor = .clear
        self.layoutMargins = .init(top: 32, left: 20, bottom: 0, right: 20)
    }
    
    private func setLayout() {
        
        // 정적 크기
        workDayButtons
            .forEach { view in
                view.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    view.widthAnchor.constraint(equalToConstant: 40),
                    view.heightAnchor.constraint(equalToConstant: 40),
                ])
            }
        
        paymentTypeButtons
            .forEach { view in
                view.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    view.widthAnchor.constraint(equalToConstant: 104),
                    view.heightAnchor.constraint(equalToConstant: 44),
                ])
            }
        
        
        let stackList: [VStack] = [
        
            VStack(
                [
                    IdleContentTitleLabel(titleText: "근무 요일"),
                    HStack([
                        workDayButtons as [UIView],
                        [UIView()]
                    ].flatMap({ $0 }), spacing: 4),
                ],
                spacing: 6,
                alignment: .fill
            ),
            
            VStack(
                [
                    IdleContentTitleLabel(titleText: "근무 시간"),
                    HStack([
                        workStartTimePicker,
                        workEndTimePicker
                    ], spacing: 4, distribution: .fillEqually),
                ],
                spacing: 6,
                alignment: .fill
            ),
            
            VStack(
                [
                    IdleContentTitleLabel(titleText: "급여"),
                    HStack([
                        paymentTypeButtons as [UIView],
                        [UIView()]
                    ].flatMap({ $0 }), spacing: 4),
                ],
                spacing: 6,
                alignment: .fill
            )
        ]
        
        let scrollView = UIScrollView()
        scrollView.delaysContentTouches = false
        scrollView.contentInset = .init(
            top: 0,
            left: 20,
            bottom: 24,
            right: 20
        )
        
        let scrollViewContentStack = VStack(
            stackList,
            spacing: 28,
            alignment: .fill
        )
        
        [
            scrollViewContentStack,
            paymentField
        ].forEach {
                
            scrollView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            scrollViewContentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            scrollViewContentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            scrollViewContentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            
            paymentField.topAnchor.constraint(equalTo: scrollViewContentStack.bottomAnchor, constant: 12),
            paymentField.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            paymentField.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            paymentField.bottomAnchor.constraint(equalTo:  scrollView.contentLayoutGuide.bottomAnchor),
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
        let workDayButtonWithItem = workDayButtons.enumerated().map { (index, button) in
            let item = WorkDay(rawValue: index)!
            return (item, button)
        }
        
        for (dayType, button) in workDayButtonWithItem {
            
            button
                .eventPublisher
                .map { state in
                    (dayType, state == .accent)
                }
                .bind(to: viewModel.selectedDay)
                .disposed(by: disposeBag)
        }
        
        workStartTimePicker
            .pickedDateString
            .map { $0.toString }
            .bind(to: viewModel.workStartTime)
            .disposed(by: disposeBag)
        
        workEndTimePicker
            .pickedDateString
            .map { $0.toString }
            .bind(to: viewModel.workEndTime)
            .disposed(by: disposeBag)
            
        Observable
            .merge(
                paymentTypeButtons
                    .enumerated()
                    .map { (index, button) in
                        let item = PaymentType(rawValue: index)!
                        return button.eventPublisher
                            .compactMap { state -> PaymentType? in state == .accent ? item : nil }
                            .asObservable()
                    }
            )
            .map { [paymentTypeButtons] (grade) in
                
                paymentTypeButtons
                    .enumerated()
                    .forEach { (index, button) in
                        let item = PaymentType(rawValue: index)!
                        if item != grade {
                            button.setState(.normal)
                        }
                    }
                
                return grade
            }
            .bind(to: viewModel.paymentType)
            .disposed(by: disposeBag)
        
        paymentField.textField.rx.text
            .compactMap { $0 }
            .bind(to: viewModel.paymentAmount)
            .disposed(by: disposeBag)
        
        // Output
        viewModel
            .workTimeAndPayNextable
            .drive(onNext: { [ctaButton] nextable in
                ctaButton.setEnabled(nextable)
            })
            .disposed(by: disposeBag)
        
        viewModel
            .workTimeAndPayStateObject
            .drive(onNext: { [weak self] stateFromVM in
                
                guard let self else { return }
                
                // 근무 요일
                for (workDay, isActive) in stateFromVM.selectedDays {
                    workDayButtons[workDay.rawValue].setState(isActive ? .accent : .normal)
                }
                
                // 시작시간
                if !stateFromVM.workStartTime.isEmpty {
                    workStartTimePicker.textLabel.textString = stateFromVM.workStartTime
                }
                
                // 종료 시간
                if !stateFromVM.workEndTime.isEmpty {
                    workEndTimePicker.textLabel.textString = stateFromVM.workEndTime
                }
                
                // 급여타입
                if let state = stateFromVM.paymentType {
                    
                    paymentTypeButtons
                        .enumerated()
                        .forEach { (index, button) in
                            let item = PaymentType(rawValue: index)!
                            
                            if item == state {
                                button.setState(.accent)
                            }
                        }
                }
                
                // 급여
                if !stateFromVM.paymentAmount.isEmpty {
                    paymentField.textField.textString = stateFromVM.paymentAmount
                }
                
            })
            .disposed(by: disposeBag)
    }
    
}
