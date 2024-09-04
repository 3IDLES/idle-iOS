//
//  WorkTimeAndPayContentView.swift
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
 
public protocol WorkTimeAndPayContentVMable {
    var selectedDay: PublishRelay<(WorkDay, Bool)> { get }
    var workStartTime: PublishRelay<IdleDateComponent> { get }
    var workEndTime: PublishRelay<IdleDateComponent> { get }
    var paymentType: PublishRelay<PaymentType> { get }
    var paymentAmount: PublishRelay<String> { get }
    
    var casting_workTimeAndPay: Driver<WorkTimeAndPayStateObject>? { get }
    var workTimeAndPayNextable: Driver<Bool>? { get }
}


// MARK: Inner view
public class WorkTimeAndPayContentView: UIView {
    
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
    public lazy var paymentField: TextFieldWithDegree = {
        let field = TextFieldWithDegree(
            degreeText: "원",
            initialText: ""
        )
        field.textField.keyboardType = .numberPad
        return field
    }()
    
    private let disposeBag = DisposeBag()
    
    public init() {
        super.init(frame: .zero)
        setLayout()
    }
    
    public required init(coder: NSCoder) { fatalError() }
    
    
    func setLayout() {
        
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
        
        let stackList: [UIView] = [
        
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
            ),
        ]
        
        let scrollViewContentStack = VStack(
            stackList,
            spacing: 28,
            alignment: .fill
        )
        
        [
            scrollViewContentStack,
            paymentField
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            scrollViewContentStack.topAnchor.constraint(equalTo: self.topAnchor),
            scrollViewContentStack.leftAnchor.constraint(equalTo: self.leftAnchor),
            scrollViewContentStack.rightAnchor.constraint(equalTo: self.rightAnchor),
            
            paymentField.topAnchor.constraint(equalTo: scrollViewContentStack.bottomAnchor, constant: 12),
            paymentField.rightAnchor.constraint(equalTo: self.rightAnchor),
            paymentField.leftAnchor.constraint(equalTo: self.leftAnchor),
            paymentField.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    public func bind(viewModel: WorkTimeAndPayContentVMable) {
        
        // Output
        
        viewModel
            .casting_workTimeAndPay?
            .drive(onNext: { [weak self] stateFromVM in
                
                guard let self else { return }
                
                // 근무 요일
                for (workDay, isActive) in stateFromVM.selectedDays {
                    workDayButtons[workDay.rawValue].setState(isActive ? .accent : .normal)
                }
                
                // 시작시간
                if let dateComponent = stateFromVM.workStartTime {
                    workStartTimePicker.textLabel.textString = dateComponent.convertToStringForButton()
                }
                
                // 종료 시간
                if let dateComponent = stateFromVM.workEndTime {
                    workEndTimePicker.textLabel.textString = dateComponent.convertToStringForButton()
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
            .pickedDateComponent
            .bind(to: viewModel.workStartTime)
            .disposed(by: disposeBag)
        
        workEndTimePicker
            .pickedDateComponent
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
    }
}
