//
//  ApplyInfoOverView.swift
//  CenterFeature
//
//  Created by choijunios on 8/5/24.
//

import Foundation
import UIKit
import BaseFeature
import PresentationCore
import RxCocoa
import RxSwift
import Entity
import DSKit

class ApplyInfoOverView: HStack, RegisterRecruitmentPostVMBindable {
    
    // Init
    
    // View
    let keyStack = VStack([], spacing: 6, alignment: .leading)
    let valueStack = VStack([], spacing: 6, alignment: .leading)
    
    let expPreferenceLabel: IdleLabel = IdleLabel(typography: .Body2)
    let applTypeLabel: IdleLabel = IdleLabel(typography: .Body2)
    let deadlineLabel: IdleLabel = IdleLabel(typography: .Body2)
    
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
            .init(title: "경력 우대여부", valueLabelView: expPreferenceLabel),
            .init(title: "지원 방법", valueLabelView: applTypeLabel),
            .init(title: "접수 마감일", valueLabelView: deadlineLabel),
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
    
    public func bind(viewModel: RegisterRecruitmentPostViewModelable) {
        
        
        
        viewModel
            .applicationDetailStateObject
            .drive(onNext: { [weak self] object in
                guard let self else { return }
                
                expPreferenceLabel.textString = object.experiencePreferenceType?.korTextForBtn ?? "오류"
                
                applTypeLabel.textString = object.applyType?.korTextForBtn ?? "오류"
                
                if let type = object.applyDeadlineType {
                    if type == .specificDate {
                        if let date = object.deadlineDate {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy. MM. dd"
                            let deadLineText = dateFormatter.string(from: date)
                            deadlineLabel.textString = deadLineText
                        } else {
                            deadlineLabel.textString = "오류"
                        }
                    } else {
                        deadlineLabel.textString = type.korTextForBtn
                    }
                    
                } else {
                    deadlineLabel.textString = "오류"
                }
            })
            .disposed(by: disposeBag)
    }
}
