//
//  CustomerInformationOverView.swift
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

public struct KeyValueListViewComponent {
    public let title: String
    public let valueLabelView: IdleLabel
    public let subValue: String?
    
    public init(title: String, valueLabelView: IdleLabel, subValue: String? = nil) {
        self.title = title
        self.valueLabelView = valueLabelView
        self.subValue = subValue
    }
}

class CustomerInformationOverView: VStack, RegisterRecruitmentPostVMBindable {
    
    // Init
    
    // View
    
    
    let nameLabel: IdleLabel = .init(typography: .Body2)
    let genderLabel: IdleLabel = .init(typography: .Body2)
    let birthYearLabel: IdleLabel = .init(typography: .Body2)
    let weightLabel: IdleLabel = .init(typography: .Body2)
    
    // ---
    
    let careGradeLabel: IdleLabel = .init(typography: .Body2)
    let cognitionStateLabel: IdleLabel = .init(typography: .Body2)
    let deceaseLabel: IdleLabel = .init(typography: .Body2)
    
    // ---
    
    let mealSupportLabel: IdleLabel = .init(typography: .Body2)
    let toiletSupportLabel: IdleLabel = .init(typography: .Body2)
    let movingSupportLabel: IdleLabel = .init(typography: .Body2)
    let dailySupportLabel: IdleLabel = .init(typography: .Body2)
    
    // ---
    let additionalTextLabel: IdleLabel = .init(typography: .Body2)
    
    // Observable
    private let disposeBag = DisposeBag()
    
    public init() {
        super.init([], spacing: 16, alignment: .fill)
        setAppearance()
        setLayout()
        setObservable()
    }
    required init(coder: NSCoder) { fatalError() }
    
    private func setAppearance() {
    }
    
    private func setLayout() {
        
        // 1
        let viewList1: [KeyValueListViewComponent] = [
            .init(title: "이름", valueLabelView: nameLabel, subValue: "고객 이름은 센터 측에서만 볼 수 있어요."),
            .init(title: "성별", valueLabelView: genderLabel),
            .init(title: "출생년도", valueLabelView: birthYearLabel),
            .init(title: "몸무게", valueLabelView: weightLabel),
        ]
        
        // 2
        let viewList2: [KeyValueListViewComponent] = [
            .init(title: "요양등급", valueLabelView: careGradeLabel),
            .init(title: "인지 상태", valueLabelView: cognitionStateLabel),
            .init(title: "질병", valueLabelView: deceaseLabel),
        ]
        
        // 3
        let viewList3: [KeyValueListViewComponent] = [
            .init(title: "식사보조", valueLabelView: mealSupportLabel),
            .init(title: "배변보조", valueLabelView: toiletSupportLabel),
            .init(title: "이동보조", valueLabelView: movingSupportLabel),
            .init(title: "일상보조", valueLabelView: dailySupportLabel),
        ]
        
        var viewListStacks: [UIView] = [
            viewList1,
            viewList2,
            viewList3,
        ].map { viewList in
            
            let keyStack = VStack([], spacing: 6, alignment: .leading)
            let valueStack = VStack([], spacing: 6, alignment: .leading)
            let keyValueStack = HStack([keyStack, valueStack, Spacer()], spacing: 32)
            
            addViewListToStack(viewList: viewList, keyStack: keyStack, valueStack: valueStack, keyValueStack: keyValueStack)
            
            return keyValueStack
        }
        
        // 4
        let keyLabel = IdleLabel(typography: .Body2)
        keyLabel.textString = "특이사항"
        keyLabel.attrTextColor = DSKitAsset.Colors.gray300.color
        keyLabel.textAlignment = .left
        
        let textView = UIView()
        textView.layer.borderColor = DSKitAsset.Colors.gray100.color.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 6
        textView.layoutMargins = .init(top: 12, left: 16, bottom: 12, right: 16)
        textView.addSubview(additionalTextLabel)
        additionalTextLabel.translatesAutoresizingMaskIntoConstraints = false
        additionalTextLabel.numberOfLines = 0
        additionalTextLabel.textAlignment = .left
        
        NSLayoutConstraint.activate([
            additionalTextLabel.topAnchor.constraint(equalTo: textView.layoutMarginsGuide.topAnchor),
            additionalTextLabel.leftAnchor.constraint(equalTo: textView.layoutMarginsGuide.leftAnchor),
            additionalTextLabel.rightAnchor.constraint(equalTo: textView.layoutMarginsGuide.rightAnchor),
            additionalTextLabel.bottomAnchor.constraint(lessThanOrEqualTo: textView.layoutMarginsGuide.bottomAnchor),
            
            textView.heightAnchor.constraint(equalToConstant: 156),
        ])
        
        let viewListStack4 = VStack([keyLabel, textView], spacing: 5.57, alignment: .fill)
        
        viewListStacks.append(viewListStack4)
        
        viewListStacks
            .enumerated()
            .forEach { (index, view) in
                self.addArrangedSubview(view)
                
                if index < viewListStacks.count-1 {
                    let divier = Spacer(height: 1)
                    divier.backgroundColor = DSKitAsset.Colors.gray100.color
                    self.addArrangedSubview(divier)
                    
                    NSLayoutConstraint.activate([
                        divier.widthAnchor.constraint(equalTo: self.widthAnchor)
                    ])
                }
            }
    }
    
    private func addViewListToStack(
        viewList: [KeyValueListViewComponent],
        keyStack: VStack,
        valueStack: VStack,
        keyValueStack: HStack
    ) {
        
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
            .casting_customerInformation
            .drive(onNext: { [weak self] object in
                guard let self else { return }
                
                nameLabel.textString = object.name
                genderLabel.textString = object.gender?.twoLetterKoreanWord ?? "오류"
                birthYearLabel.textString = object.birthYear
                weightLabel.textString = object.weight
                
                if let careGrade = object.careGrade {
                    let text: String = careGrade.textForCellBtn + "등급"
                    careGradeLabel.textString = text
                } else {
                    careGradeLabel.textString = "오류"
                }
                
                if let cognitionState = object.cognitionState {
                    cognitionStateLabel.textString = cognitionState.korTextForCellBtn
                } else {
                    cognitionStateLabel.textString = "오류"
                }
                
                deceaseLabel.textString = object.deceaseDescription.isEmpty ? "-" : object.deceaseDescription
            })
            .disposed(by: disposeBag)
        
        viewModel
            .casting_customerRequirement
            .drive(onNext: { [weak self] object in
                guard let self else { return }
                
                mealSupportLabel.textString = object.mealSupportNeeded == true ? "필요" : "불필요"
                toiletSupportLabel.textString = object.toiletSupportNeeded == true ? "필요" : "불필요"
                movingSupportLabel.textString = object.movingSupportNeeded == true ? "필요" : "불필요"
                
                let dailySupportText = object.dailySupportTypeNeeds.compactMap { (day, isActive) -> String? in
                    return isActive ? day.korLetterTextForBtn : nil
                }.joined(separator: ", ")
                
                dailySupportLabel.textString = dailySupportText
                
                additionalTextLabel.textString = object.additionalRequirement
            })
            .disposed(by: disposeBag)
    }
}

