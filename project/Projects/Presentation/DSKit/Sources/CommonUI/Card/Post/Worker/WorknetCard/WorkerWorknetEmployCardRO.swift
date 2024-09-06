//
//  WorkerWorknetEmployCardRO.swift
//  DSKit
//
//  Created by choijunios on 9/6/24.
//

import Foundation

public struct WorkerWorknetEmployCardRO {
    
    public let showBeginnerTag: Bool
    public let leftDayUnitlDeadlineText: String
    public let titleText: String
    public let timeDurationForWalkingText: String
    public let workTimeInfoText: String
    public let paymentInfoText: String
    public let isStarred: Bool
    
    public init(
        showBeginnerTag: Bool,
        leftDayUnitlDeadlineText: String,
        titleText: String,
        timeDurationForWalkingText: String,
        workTimeInfoText: String,
        paymentInfoText: String,
        isStarred: Bool
    ) {
        self.showBeginnerTag = showBeginnerTag
        self.leftDayUnitlDeadlineText = leftDayUnitlDeadlineText
        self.titleText = titleText
        self.timeDurationForWalkingText = timeDurationForWalkingText
        self.workTimeInfoText = workTimeInfoText
        self.paymentInfoText = paymentInfoText
        self.isStarred = isStarred
    }
}
