//
//  WorkerWorknetEmployCard.swift
//  DSKit
//
//  Created by choijunios on 9/6/24.
//

import UIKit
import RxSwift
import RxCocoa
import Entity

public class WorkerWorknetEmployCard: VStack {
    
    // View
    public let starButton: IconWithColorStateButton = {
        let button = IconWithColorStateButton(
            representImage: DSKitAsset.Icons.subscribeStar.image,
            normalColor: DSKitAsset.Colors.gray200.color,
            accentColor: DSKitAsset.Colors.orange300.color
        )
        return button
    }()
    
    
    // tags
    let worknetTag: TagLabel = {
        let tag = TagLabel(
            text: "워크넷",
            typography: .caption,
            textColor: hexStringToUIColor(hex: "#2B8BDC"),
            backgroundColor: hexStringToUIColor(hex: "#D3EBFF")
        )
        return tag
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
    let daysUntilDeadlineTag: TagLabel = {
        let tag = TagLabel(
            text: "",
            typography: .caption,
            textColor: DSKitAsset.Colors.orange500.color,
            backgroundColor: DSKitAsset.Colors.orange100.color
        )
        return tag
    }()
    
    
    let titleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle2)
        label.numberOfLines = 0
        return label
    }()
    
    
    let estimatedArrivalTimeLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        label.attrTextColor = DSKitAsset.Colors.gray500.color
        label.numberOfLines = 0
        return label
    }()
    
    
    let workTimeLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        label.attrTextColor = DSKitAsset.Colors.gray500.color
        label.numberOfLines = 0
        return label
    }()
    
    
    let payLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        label.attrTextColor = DSKitAsset.Colors.gray500.color
        label.numberOfLines = 0
        return label
    }()
    
    public init() {
        super.init([], alignment: .fill)
        setAppearance()
        setLayout()
    }
    public required init(coder: NSCoder) { fatalError() }
    
    func setAppearance() { 
        self.backgroundColor = DSColor.gray0.color
    }
    
    func setLayout() {
        
        // MARK: Tag & Star
        let tagStack = HStack(
            [
                worknetTag,
                beginnerTag,
                daysUntilDeadlineTag,
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
        
        // MARK: work days | work time
        let timeImage = DSKitAsset.Icons.time.image.toView()
        let workTimeStack = HStack(
            [
                timeImage,
                workTimeLabel
            ],
            alignment: .center,
            distribution: .fill
        )
        
        // MARK: pay
        let payImage = DSKitAsset.Icons.money.image.toView()
        let paymentStack = HStack(
            [
                payImage,
                payLabel
            ],
            alignment: .center,
            distribution: .fill
        )
        
        NSLayoutConstraint.activate([
            timeImage.widthAnchor.constraint(equalToConstant: 24),
            timeImage.heightAnchor.constraint(equalTo: timeImage.widthAnchor),
            payImage.widthAnchor.constraint(equalToConstant: 24),
            payImage.heightAnchor.constraint(equalTo: payImage.widthAnchor),
            starButton.widthAnchor.constraint(equalToConstant: 24),
            starButton.heightAnchor.constraint(equalTo: starButton.widthAnchor),
        ])
        
        let viewList = [
            tagStarStack,
            Spacer(height: 8),
            titleLabel,
            Spacer(height: 8),
            VStack([
                estimatedArrivalTimeLabel,
                Spacer(height: 4),
                workTimeStack,
                Spacer(height: 2),
                paymentStack
            ], alignment: .leading)
        ]
        
        viewList.forEach {
            self.addArrangedSubview($0)
        }
    }
    
    public func applyRO(ro: WorkerWorknetEmployCardRO) {
        
        beginnerTag.isHidden = !ro.showBeginnerTag
        daysUntilDeadlineTag.textString = ro.leftDayUnitlDeadlineText
        starButton.setState(ro.isStarred ? .accent : .normal)
        titleLabel.textString = ro.titleText
        estimatedArrivalTimeLabel.textString = ro.timeDurationForWalkingText
        workTimeLabel.textString = ro.workTimeInfoText
        payLabel.textString = ro.paymentInfoText
    }
}

func hexStringToUIColor(hex: String) -> UIColor {
    var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if cString.hasPrefix("#") {
        cString.remove(at: cString.startIndex)
    }

    if cString.count != 6 {
        return UIColor.gray // 기본 색상
    }

    var rgbValue: UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)

    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: 1.0
    )
}

@available(iOS 17.0, *)
#Preview("Preview", traits: .defaultLayout) {
    let cardView = WorkerWorknetEmployCard()
    
    cardView.applyRO(
        ro: .init(
            showBeginnerTag: true,
            leftDayUnitlDeadlineText: "D-10",
            titleText: "[수원 매탄동] 방문요양 주 3회 (4등급 여자 어르신)",
            timeDurationForWalkingText: "도보 15분~20분",
            workTimeInfoText: "주 6일 근무 | (오전) 1시 00분 ~ (오후) 4시 00분 ",
            paymentInfoText: "시급 9,860원 이상",
            isStarred: true
        )
    )
    
    return cardView
}
