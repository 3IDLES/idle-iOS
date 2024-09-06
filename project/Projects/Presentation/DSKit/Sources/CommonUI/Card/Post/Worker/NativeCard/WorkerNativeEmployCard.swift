//
//  WorkerNativeEmployCard.swift
//  DSKit
//
//  Created by choijunios on 9/6/24.
//

import UIKit
import RxSwift
import RxCocoa
import Entity

public class WorkerNativeEmployCard: UIView {
    
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
    let timeDurationForWorkingTag: TagLabel = {
        let tag = TagLabel(
            text: "",
            typography: .caption,
            textColor: DSKitAsset.Colors.gray300.color,
            backgroundColor: DSKitAsset.Colors.gray050.color
        )
        return tag
    }()
    
    
    let titleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle2)
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
    
    let payLabel: IdleLabel = {
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
    
    func setAppearance() { 
        self.backgroundColor = DSColor.gray0.color
    }
    
    func setLayout() {
        
        // MARK: tag & star
        let tagStack = HStack(
            [
                beginnerTag,
                timeDurationForWorkingTag
            ],
            spacing: 4
        )
        
        let tagStarStack = HStack(
            [
                tagStack,
                Spacer(),
                starButton
            ],
            alignment: .center,
            distribution: .fill
        )
        tagStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        starButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        NSLayoutConstraint.activate([
            starButton.widthAnchor.constraint(equalToConstant: 24),
            starButton.heightAnchor.constraint(equalTo: starButton.widthAnchor),
        ])
        
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
            payLabel
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
            
            payLabel.leadingAnchor.constraint(equalTo: payImage.trailingAnchor, constant: 2),
            payLabel.centerYAnchor.constraint(equalTo: payImage.centerYAnchor),
            
            payView.trailingAnchor.constraint(equalTo: payLabel.trailingAnchor),
        ])
        
        
        let stackList = [
            tagStarStack,
            Spacer(height: 8),
            VStack(
                [
                    titleLabel, serviceTargetInfoLabel
                ],
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
    
    public func setToPostAppearance() {
        titleLabel.typography = .Subtitle1
        serviceTargetInfoLabel.typography = .Body3
        workDaysLabel.typography = .Body2
        workTimeLabel.typography = .Body2
        payLabel.typography = .Body2
    }
    
    public func bind(ro: WorkerNativeEmployCardRO) {
        beginnerTag.isHidden = !ro.showBiginnerTag
        timeDurationForWorkingTag.textString = ro.timeDurationForWalkingText
        titleLabel.textString = ro.titleText
        serviceTargetInfoLabel.textString = ro.targetInfoText
        workDaysLabel.textString = ro.workDaysText
        workTimeLabel.textString = ro.workTimeText
        payLabel.textString = ro.payText
        starButton.setState(ro.isFavorite ? .accent : .normal, withAnimation: false)
    }
}
