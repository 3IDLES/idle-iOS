//
//  WorkerWorknetEmployCardRO.swift
//  DSKit
//
//  Created by choijunios on 9/6/24.
//

import Foundation
import Entity

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
    
    public static func create(vo: WorknetRecruitmentPostDetailVO) -> WorkerWorknetEmployCardRO {
        
        var leftDayUnitlDeadlineText: String = "타임존 다름"
        if let dateDiff = Calendar.current.dateComponents([.day], from: .now, to: vo.applyDeadline).day {
            leftDayUnitlDeadlineText = "D-\(dateDiff)"
            if dateDiff == 0 {
                leftDayUnitlDeadlineText = "D-Day"
            }
        }
        
        let durationText = Self.timeForDistance(meter: vo.distance)
        
        return .init(
            showBeginnerTag: false,
            leftDayUnitlDeadlineText: leftDayUnitlDeadlineText,
            titleText: vo.title,
            timeDurationForWalkingText: durationText,
            workTimeInfoText: "\(vo.workingSchedule) | \(vo.workingTime)",
            paymentInfoText: vo.payInfo,
            isStarred: vo.isFavorite
        )
    }
    
    public static func create(vo: WorknetRecruitmentPostVO) -> WorkerWorknetEmployCardRO {
        
        var leftDayUnitlDeadlineText: String = "타임존 다름"
        if let dateDiff = Calendar.current.dateComponents([.day], from: .now, to: vo.applyDeadline).day {
            leftDayUnitlDeadlineText = "D-\(dateDiff)"
            if dateDiff == 0 {
                leftDayUnitlDeadlineText = "D-Day"
            }
        }
        
        let durationText = Self.timeForDistance(meter: vo.distance)
        
        return .init(
            showBeginnerTag: false,
            leftDayUnitlDeadlineText: leftDayUnitlDeadlineText,
            titleText: vo.title,
            timeDurationForWalkingText: durationText,
            workTimeInfoText: "\(vo.workingSchedule) | \(vo.workingTime)",
            paymentInfoText: vo.payInfo,
            isStarred: vo.isFavorite
        )
    }
    
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
