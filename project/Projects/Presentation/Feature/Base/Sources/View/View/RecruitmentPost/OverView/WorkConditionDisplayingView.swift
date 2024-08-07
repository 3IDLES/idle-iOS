//
//  WorkConditionDisplayingView.swift
//  BaseFeature
//
//  Created by choijunios on 8/7/24.
//

import Foundation
import UIKit
import PresentationCore
import RxCocoa
import RxSwift
import Entity
import DSKit

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
            [keyStack, valueStack, Spacer()],
            spacing: 32
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

public extension WorkConditionOverView {
    
    func bind(viewModel: WorkTimeAndPayContentVMable & AddressInputViewContentVMable) {
        
        viewModel
            .casting_workTimeAndPay
            .drive(onNext: { [weak self] object in
                guard let self else { return }
                
                let daysText = object.selectedDays.compactMap { (day, isActive) -> String? in
                    return isActive ? day.korOneLetterText : nil
                }.joined(separator: ", ")
                
                workDaysLabel.textString = daysText
                
                let workTimeText = [
                    object.workStartTime?.convertToStringForButton() ?? "00:00",
                    object.workEndTime?.convertToStringForButton() ?? "00:00"
                ].joined(separator: " - ")
                
                workTimeLabel.textString = workTimeText
                
                let paymentTypeText = object.paymentType?.korLetterText ?? "오류"
                let paymentAmountText = object.paymentAmount
                
                workPaymentLabel.textString = "\(paymentTypeText) \(paymentAmountText)원"
            })
            .disposed(by: disposeBag)
        
        viewModel
            .casting_addressInput
            .drive(onNext: { [weak self] object in
                guard let self else { return }
                
                workLocationLabel.textString = object.addressInfo?.roadAddress ?? "오류"
            })
            .disposed(by: disposeBag)
    }
}
