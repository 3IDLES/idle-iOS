//
//  WorkerEmployCard.swift
//  DSKit
//
//  Created by choijunios on 7/19/24.
//

import UIKit
import RxSwift
import RxCocoa
import Entity

public class WorkerEmployCard: UIView {
    
    // View
    public let starButton: IconWithColorStateButton = {
        let button = IconWithColorStateButton(
            representImage: DSKitAsset.Icons.subscribeStar.image,
            normalColor: DSKitAsset.Colors.gray200.color,
            accentColor: DSKitAsset.Colors.orange300.color
        )
        return button
    }()
    
    let beginnerTag: TagLabel = {
        let tag = TagLabel(
            text: "초보가능",
            typography: .caption,
            textColor: DSKitAsset.Colors.orange500.color,
            backgroundColor: DSKitAsset.Colors.orange100.color
        )
        return tag
    }()
    let dayLeftTag: TagLabel = {
        let tag = TagLabel(
            text: "",
            typography: .caption,
            textColor: DSKitAsset.Colors.gray300.color,
            backgroundColor: DSKitAsset.Colors.gray100.color
        )
        return tag
    }()
    
    
    let titleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle2)
        return label
    }()
    let timeTakenForWalkLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        label.attrTextColor = DSKitAsset.Colors.gray500.color
        return label
    }()
    
    let serviceTargetInfoLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body2)
        return label
    }()
    
    let workDaysLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        label.attrTextColor = DSKitAsset.Colors.gray500.color
        return label
    }()
    let workTimeLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        label.attrTextColor = DSKitAsset.Colors.gray500.color
        return label
    }()
    
    let payPerHourLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        label.attrTextColor = DSKitAsset.Colors.gray500.color
        return label
    }()
    
    public init() {
        super.init(frame: .zero)
        setAppearance()
        setLayout()
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    func setAppearance() { }
    
    func setLayout() {
        
        // MARK: tag & star
        let tagStack = HStack(
            [
                beginnerTag,
                dayLeftTag
            ],
            spacing: 4
        )
        
        let tagStarStack = HStack(
            [
                tagStack,
                starButton
            ],
            alignment: .center,
            distribution: .equalSpacing
        )
        tagStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        starButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        NSLayoutConstraint.activate([
            starButton.widthAnchor.constraint(equalToConstant: 24),
            starButton.heightAnchor.constraint(equalTo: starButton.widthAnchor),
        ])
        
        // MARK: Title & takenTimesForWalk
        let titleStack = HStack(
            [
                titleLabel,
                timeTakenForWalkLabel
            ],
            spacing: 8,
            alignment: .bottom
        )
        
        let divider = UIView()
        divider.backgroundColor = DSKitAsset.Colors.gray300.color
    
        // MARK: work day & time
        let timeImage = DSKitAsset.Icons.time.image.toView()
        let workDayAndTimeView = UIView()
        workDayAndTimeView.backgroundColor = .clear
        [
            timeImage,
            workDaysLabel,
            divider,
            workTimeLabel
        ]
        .forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            workDayAndTimeView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            timeImage.widthAnchor.constraint(equalToConstant: 24),
            timeImage.heightAnchor.constraint(equalTo: timeImage.widthAnchor),
            
            workDayAndTimeView.topAnchor.constraint(equalTo: timeImage.topAnchor),
            workDayAndTimeView.leadingAnchor.constraint(equalTo: timeImage.leadingAnchor),
            workDayAndTimeView.bottomAnchor.constraint(equalTo: timeImage.bottomAnchor),
            
            workDaysLabel.leadingAnchor.constraint(equalTo: timeImage.trailingAnchor, constant: 2),
            workDaysLabel.centerYAnchor.constraint(equalTo: timeImage.centerYAnchor),
            
            divider.leadingAnchor.constraint(equalTo: workDaysLabel.trailingAnchor, constant: 6),
            divider.centerYAnchor.constraint(equalTo: timeImage.centerYAnchor),
            divider.widthAnchor.constraint(equalToConstant: 1),
            divider.heightAnchor.constraint(equalToConstant: 16),
            
            workTimeLabel.leadingAnchor.constraint(equalTo: divider.trailingAnchor, constant: 5),
            workTimeLabel.centerYAnchor.constraint(equalTo: timeImage.centerYAnchor),
            
            workDayAndTimeView.trailingAnchor.constraint(equalTo: workTimeLabel.trailingAnchor),
        ])
        
        // MARK: pay
        let payImage = DSKitAsset.Icons.money.image.toView()
        let payView = UIView()
        payView.backgroundColor = .clear
        [
            payImage,
            payPerHourLabel
        ]
        .forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            payView.addSubview($0)
        }
        NSLayoutConstraint.activate([
            payImage.widthAnchor.constraint(equalToConstant: 24),
            payImage.heightAnchor.constraint(equalTo: payImage.widthAnchor),
            
            payView.topAnchor.constraint(equalTo: payImage.topAnchor),
            payView.leadingAnchor.constraint(equalTo: payImage.leadingAnchor),
            payView.bottomAnchor.constraint(equalTo: payImage.bottomAnchor),
            
            payPerHourLabel.leadingAnchor.constraint(equalTo: payImage.trailingAnchor, constant: 2),
            payPerHourLabel.centerYAnchor.constraint(equalTo: payImage.centerYAnchor),
            
            payView.trailingAnchor.constraint(equalTo: payPerHourLabel.trailingAnchor),
        ])
        
        
        let stackList = [
            tagStarStack,
            Spacer(height: 8),
            VStack(
                [titleStack,serviceTargetInfoLabel],
                spacing: 2,
                alignment: .leading
            ),
            Spacer(height: 4),
            VStack(
                [workDayAndTimeView, payView],
                spacing: 2,
                alignment: .leading
            )
        ]
            
        
        let mainStack = VStack(
            stackList,
            alignment: .fill
        )
        
        [
            mainStack
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: self.topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
    
    public func bind(vo: WorkerEmployCardVO) {
        
        beginnerTag.isHidden = !vo.isBeginnerPossible
        if vo.dayLeft <= 0 {
            if vo.dayLeft == 0 {
                dayLeftTag.textString = "D-Day"
            } else {
                dayLeftTag.isHidden = true
            }
        } else {
            dayLeftTag.textString = "D-\(vo.dayLeft)"
        }
        titleLabel.textString = vo.title
        timeTakenForWalkLabel.textString = vo.timeTakenForWalk
        serviceTargetInfoLabel.textString = "\(vo.targetLevel)등급 \(vo.targetAge)세 \(vo.targetGender.twoLetterKoreanWord)"
        workDaysLabel.textString = vo.days.map({ $0.korOneLetterText }).joined(separator: ",")
        workTimeLabel.textString = "\(vo.startTime) - \(vo.endTime)"
        payPerHourLabel.textString = "\(vo.paymentType.korLetterText) \(vo.paymentAmount) 원"
    }
}
