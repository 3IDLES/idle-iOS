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

public class WorkerEmployCardRO {
    
    let showBiginnerTag: Bool
    let showDayLeftTag: Bool
    let dayLeftTagText: String?
    let titleText: String
    let distanceFromWorkPlaceText: String
    let targetInfoText: String
    let workDaysText: String
    let workTimeText: String
    let payText: String
    
    init(showBiginnerTag: Bool, showDayLeftTag: Bool, dayLeftTagText: String?, titleText: String, distanceFromWorkPlace: String, targetInfoText: String, workDaysText: String, workTimeText: String, payText: String) {
        self.showBiginnerTag = showBiginnerTag
        self.showDayLeftTag = showDayLeftTag
        self.dayLeftTagText = dayLeftTagText
        self.titleText = titleText
        self.distanceFromWorkPlaceText = distanceFromWorkPlace
        self.targetInfoText = targetInfoText
        self.workDaysText = workDaysText
        self.workTimeText = workTimeText
        self.payText = payText
    }
    
    public static func create(vo: WorkerEmployCardVO) -> WorkerEmployCardRO {

        var dayLeftTagText: String? = nil
        var showDayLeftTag: Bool = false
        
        if (0...14).contains(vo.dayLeft) {
            showDayLeftTag = true
            dayLeftTagText = vo.dayLeft == 0 ? "D-Day" : "D-\(vo.dayLeft)"
        }
       
        let targetInfoText = "\(vo.careGrade.textForCellBtn)등급 \(vo.targetAge)세 \(vo.targetGender.twoLetterKoreanWord)"
        
        let workDaysText = vo.days.sorted(by: { d1, d2 in
            d1.rawValue < d2.rawValue
        }).map({ $0.korOneLetterText }).joined(separator: ",")
        
        let workTimeText = "\(vo.startTime) - \(vo.endTime)"
        let payText = "\(vo.paymentType.korLetterText) \(vo.paymentAmount) 원"
        
        var splittedAddress = vo.title.split(separator: " ")
        
        if splittedAddress.count >= 3 {
            splittedAddress = Array(splittedAddress[0..<3])
        }
        let addressTitle = splittedAddress.joined(separator: " ")
        
        return .init(
            showBiginnerTag: vo.isBeginnerPossible,
            showDayLeftTag: showDayLeftTag,
            dayLeftTagText: dayLeftTagText,
            titleText: addressTitle,
            distanceFromWorkPlace: "\(vo.distanceFromWorkPlace)m",
            targetInfoText: targetInfoText,
            workDaysText: workDaysText,
            workTimeText: workTimeText,
            payText: payText
        )
    }
    
    public static let `mock`: WorkerEmployCardRO = .init(
        showBiginnerTag: true,
        showDayLeftTag: true,
        dayLeftTagText: "D-14",
        titleText: "사울시 강남동",
        distanceFromWorkPlace: "1.1km",
        targetInfoText: "1등급 54세 여성",
        workDaysText: "",
        workTimeText: "월, 화, 수",
        payText: "시급 5000원"
    )
}


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
    let distanceFromWorkPlaceLabel: IdleLabel = {
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
                distanceFromWorkPlaceLabel
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
    
    public func setToPostAppearance() {
        titleLabel.typography = .Subtitle1
        distanceFromWorkPlaceLabel.isHidden = true
        serviceTargetInfoLabel.typography = .Body3
        workDaysLabel.typography = .Body2
        workTimeLabel.typography = .Body2
        payLabel.typography = .Body2
    }
    
    public func bind(ro: WorkerEmployCardRO) {
        
        beginnerTag.isHidden = !ro.showBiginnerTag
        dayLeftTag.isHidden = !ro.showDayLeftTag
        dayLeftTag.textString = ro.dayLeftTagText ?? ""
        titleLabel.textString = ro.titleText
        distanceFromWorkPlaceLabel.textString = ro.distanceFromWorkPlaceText
        serviceTargetInfoLabel.textString = ro.targetInfoText
        workDaysLabel.textString = ro.workDaysText
        workTimeLabel.textString = ro.workTimeText
        payLabel.textString = ro.payText
    }
}
