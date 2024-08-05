//
//  AdditionalApplyInfoOverView.swift
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

class AdditionalApplyInfoOverView: HStack, RegisterRecruitmentPostVMBindable {
    
    // Init
    
    // View
    let keyStack = VStack([], spacing: 6, alignment: .leading)
    let valueStack = VStack([], spacing: 6, alignment: .leading)
    
    let nameLabel: IdleLabel = IdleLabel(typography: .Body2)
    let genderLabel: IdleLabel = IdleLabel(typography: .Body2)
    let birthYearLabel: IdleLabel = IdleLabel(typography: .Body2)
    let weightLabel: IdleLabel = IdleLabel(typography: .Body2)
    
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
            .init(title: "이름", valueLabelView: nameLabel, subValue: "고객 이름은 센터 측에서만 볼 수 있어요."),
            .init(title: "성별", valueLabelView: genderLabel),
            .init(title: "출생년도", valueLabelView: birthYearLabel),
            .init(title: "몸무게", valueLabelView: weightLabel),
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
            .customerInformationStateObject
            .drive(onNext: { [weak self] object in
                guard let self else { return }
                
                nameLabel.textString = object.name
                genderLabel.textString = object.gender?.twoLetterKoreanWord ?? "오류"
                birthYearLabel.textString = object.birthYear
                weightLabel.textString = object.weight
            })
            .disposed(by: disposeBag)
    }
}

