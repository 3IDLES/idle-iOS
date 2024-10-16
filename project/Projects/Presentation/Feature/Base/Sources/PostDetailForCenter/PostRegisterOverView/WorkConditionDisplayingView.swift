//
//  WorkConditionDisplayingView.swift
//  BaseFeature
//
//  Created by choijunios on 8/7/24.
//

import UIKit
import PresentationCore
import Domain
import DSKit


import RxCocoa
import RxSwift

public protocol WorkConditionDisplayingVMable {
    
    var casting_workTimeAndPay: Driver<WorkTimeAndPayStateObject>? { get }
    var casting_addressInput: Driver<AddressInputStateObject>? { get }
}

public class WorkConditionDisplayingView: HStack {
    
    // Init
    
    // View
    let keyStack = VStack([], spacing: 6, alignment: .leading)
    let valueStack = VStack([], spacing: 6, alignment: .leading)
    
    let workDaysLabel: IdleLabel = IdleLabel(typography: .Body2)
    let workTimeLabel: IdleLabel = IdleLabel(typography: .Body2)
    let workPaymentLabel: IdleLabel = IdleLabel(typography: .Body2)
    let workLocationLabel: IdleLabel = IdleLabel(typography: .Body2)
    
    // Observable
    private let disposeBag = DisposeBag()
    
    public init() {
        super.init(
            [keyStack, Spacer(width: 32), valueStack, Spacer()],
            distribution: .fill
        )
        setAppearance()
        setLayout()
        setObservable()
    }
    required init(coder: NSCoder) { fatalError() }
    
    private func setAppearance() {
    }
    
    private func setLayout() {
        
        keyStack.setContentHuggingPriority(.init(750), for: .horizontal)
        valueStack.setContentHuggingPriority(.init(751), for: .horizontal)
        
        let viewList: [KeyValueListViewComponent] = [
            .init(title: "근무 요일", valueLabelView: workDaysLabel),
            .init(title: "근무 시간", valueLabelView: workTimeLabel),
            .init(title: "급여", valueLabelView: workPaymentLabel),
            .init(title: "근무 주소", valueLabelView: workLocationLabel),
        ]
        
        viewList.forEach { component in
            
            let keyLabel = IdleLabel(typography: .Body2)
            keyLabel.textString = component.title
            keyLabel.attrTextColor = DSKitAsset.Colors.gray300.color
            keyLabel.textAlignment = .left

            if let subTitleText = component.subValue {
                
                let subValueLabel = IdleLabel(typography: .caption)
                subValueLabel.textString = subTitleText
                subValueLabel.attrTextColor = DSKitAsset.Colors.gray300.color
                subValueLabel.textAlignment = .left
                
                let keyLabelStack = VStack([keyLabel, Spacer()], alignment: .fill)
                let valueLabelStack = VStack([component.valueLabelView, subValueLabel], alignment: .fill)
                
                keyStack.addArrangedSubview(keyLabelStack)
                valueStack.addArrangedSubview(valueLabelStack)
                
                keyStack.translatesAutoresizingMaskIntoConstraints = false
                valueStack.translatesAutoresizingMaskIntoConstraints = false
                
                NSLayoutConstraint.activate([
                    keyLabelStack.heightAnchor.constraint(equalTo: valueLabelStack.heightAnchor)
                ])
                
            } else {
                
                keyStack.addArrangedSubview(keyLabel)
                valueStack.addArrangedSubview(component.valueLabelView)
                
                keyStack.translatesAutoresizingMaskIntoConstraints = false
                valueStack.translatesAutoresizingMaskIntoConstraints = false
                
                NSLayoutConstraint.activate([
                    keyStack.heightAnchor.constraint(equalTo: valueStack.heightAnchor)
                ])
            }
        }
    }
    
    private func setObservable() { }
}

public extension WorkConditionDisplayingView {
    
    private func applyObject(_ object: WorkTimeAndPayStateObject) {
        let daysText = object.selectedDays.compactMap { (day, isActive) -> WorkDay? in
            return isActive ? day : nil
        }.sorted(by: { lhs, rhs in
            lhs.rawValue < rhs.rawValue
        })
        .map({
            $0.korOneLetterText
        })
        .joined(separator: ", ")
        
        workDaysLabel.textString = daysText
        
        let workTimeText = [
            object.workStartTime?.convertToStringForButton() ?? "00:00",
            object.workEndTime?.convertToStringForButton() ?? "00:00"
        ].joined(separator: " - ")
        
        workTimeLabel.textString = workTimeText
        
        let paymentTypeText = object.paymentType?.korLetterText ?? "오류"
        
        let payAmount = String(object.paymentAmount)
        var formedPayAmountText = ""
        for (index, char) in payAmount.reversed().enumerated() {
            if (index % 3) == 0, index != 0 {
                formedPayAmountText = "," + formedPayAmountText
            }
            formedPayAmountText = String(char) + formedPayAmountText
        }
        workPaymentLabel.textString = "\(paymentTypeText) \(formedPayAmountText)원"
    }
    
    private func applyObject(_ object: AddressInputStateObject) {
        workLocationLabel.textString = object.addressInfo?.roadAddress ?? "오류"
    }
    
    func bind(
        workTimeAndPayStateObject: WorkTimeAndPayStateObject,
        addressInputStateObject: AddressInputStateObject
    ) {
        applyObject(workTimeAndPayStateObject)
        applyObject(addressInputStateObject)
    }
    
    func bind(viewModel: WorkConditionDisplayingVMable) {
        
        viewModel
            .casting_workTimeAndPay?
            .drive(onNext: { [weak self] object in
                guard let self else { return }
                applyObject(object)
            })
            .disposed(by: disposeBag)
        
        viewModel
            .casting_addressInput?
            .drive(onNext: { [weak self] object in
                guard let self else { return }
                applyObject(object)
            })
            .disposed(by: disposeBag)
    }
}
