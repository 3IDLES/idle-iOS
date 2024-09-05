//
//  WorkerNativeEmployCardRO.swift
//  DSKit
//
//  Created by choijunios on 7/19/24.
//

import UIKit
import RxSwift
import RxCocoa
import Entity

public class WorkerNativeEmployCardRO {
    
    let showBiginnerTag: Bool
    let titleText: String
    let timeDurationForWalkingText: String
    let targetInfoText: String
    let workDaysText: String
    let workTimeText: String
    let payText: String
    let isFavorite: Bool
    
    init(
        showBiginnerTag: Bool,
        titleText: String,
        timeDurationForWalkingText: String,
        targetInfoText: String,
        workDaysText: String,
        workTimeText: String,
        payText: String,
        isFavorite: Bool
    ) {
        self.showBiginnerTag = showBiginnerTag
        self.titleText = titleText
        self.timeDurationForWalkingText = timeDurationForWalkingText
        self.targetInfoText = targetInfoText
        self.workDaysText = workDaysText
        self.workTimeText = workTimeText
        self.payText = payText
        self.isFavorite = isFavorite
    }
    
    public static func create(vo: WorkerNativeEmployCardVO) -> WorkerNativeEmployCardRO {

//        var dayLeftTagText: String? = nil
//        var showDayLeftTag: Bool = false
//        
//        if (0...14).contains(vo.dayLeft) {
//            showDayLeftTag = true
//            dayLeftTagText = vo.dayLeft == 0 ? "D-Day" : "D-\(vo.dayLeft)"
//        }
       
        let targetInfoText = "\(vo.careGrade.textForCellBtn)등급 \(vo.targetAge)세 \(vo.targetGender.twoLetterKoreanWord)"
        
        let workDaysText = vo.days.sorted(by: { d1, d2 in
            d1.rawValue < d2.rawValue
        }).map({ $0.korOneLetterText }).joined(separator: ",")
        
        let workTimeText = "\(vo.startTime) - \(vo.endTime)"
        
        var formedPayAmountText = ""
        for (index, char) in vo.paymentAmount.reversed().enumerated() {
            if (index % 3) == 0, index != 0 {
                formedPayAmountText = "," + formedPayAmountText
            }
            formedPayAmountText = String(char) + formedPayAmountText
        }
        
        let payText = "\(vo.paymentType.korLetterText) \(formedPayAmountText) 원"
        
        var splittedAddress = vo.title.split(separator: " ")
        
        if splittedAddress.count >= 3 {
            splittedAddress = Array(splittedAddress[0..<3])
        }
        let addressTitle = splittedAddress.joined(separator: " ")
        
        // distance는 미터단위입니다.
        let durationText = Self.timeForDistance(meter: vo.distanceFromWorkPlace)
        
        return .init(
            showBiginnerTag: vo.isBeginnerPossible,
            titleText: addressTitle,
            timeDurationForWalkingText: durationText,
            targetInfoText: targetInfoText,
            workDaysText: workDaysText,
            workTimeText: workTimeText,
            payText: payText,
            isFavorite: vo.isFavorite
        )
    }
    
    public static let `mock`: WorkerNativeEmployCardRO = .init(
        showBiginnerTag: true,
        titleText: "사울시 강남동",
        timeDurationForWalkingText: "도보 15분 ~ 20분",
        targetInfoText: "1등급 54세 여성",
        workDaysText: "",
        workTimeText: "월, 화, 수",
        payText: "시급 5000원",
        isFavorite: true
    )
    
    static func timeForDistance(meter: Int) -> String {
        switch meter {
        case 0..<200:
            return "도보 5분 이내"
        case 200..<400:
            return "도보 5 ~ 10분"
        case 400..<700:
            return "도보 10 ~ 15분"
        case 700..<1000:
            return "도보 15 ~ 20분"
        case 1000..<1250:
            return "도보 20 ~ 25분"
        case 1250..<1500:
            return "도보 25 ~ 30분"
        case 1500..<1750:
            return "도보 30 ~ 35분"
        case 1750..<2000:
            return "도보 35 ~ 40분"
        default:
            return "도보 40분 ~"
        }
    }

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
