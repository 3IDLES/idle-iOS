//
//  RecuritmentPostListForWorkerDTO.swift
//  NetworkDataSource
//
//  Created by choijunios on 8/16/24.
//

import Foundation
import Entity

public struct RecruitmentPostListForWorkerDTO: Codable {

    public let items: [RecruitmentPostForWorkerDTO]
    public let next: String?
    public let fetchedPostCount: Int
    
    public func toEntity() -> RecruitmentPostListForWorkerVO {
        
        return .init(
            posts: items.map { $0.toEntity() },
            nextPageId: next,
            fetchedPostCount: fetchedPostCount
        )
    }
}

public struct RecruitmentPostForWorkerDTO: Codable {
    public let isExperiencePreferred: Bool
    public let id: String
    public let weekdays: [String]
    public let startTime: String
    public let endTime: String
    public let payType: String
    public let payAmount: Int
    public let roadNameAddress: String
    public let lotNumberAddress: String
    public let gender: String
    public let age: Int
    public let careLevel: Int
    public let applyDeadlineType: String
    public let applyDeadline: String?
    public let distance: Int
    
    public func toEntity() -> RecruitmentPostForWorkerVO {
        
        let weekDayList = weekdays.map({ dayText in
            WorkDay.toEntity(text: dayText)
        })
        
        let payAmount = String(payAmount)
        var formedPayAmount = ""
        for (index, char) in payAmount.reversed().enumerated() {
            if (index % 3) == 0, index != 0 {
                formedPayAmount += ","
            }
            formedPayAmount += String(char)
        }
        
        return .init(
            postId: id,
            weekdays: weekDayList,
            startTime: startTime,
            endTime: endTime,
            roadNameAddress: roadNameAddress,
            lotNumberAddress: lotNumberAddress,
            gender: Gender.toEntity(text: gender),
            age: age,
            careLevel: CareGrade(rawValue: careLevel-1)!,
            isExperiencePreferred: isExperiencePreferred,
            applyDeadlineType: ApplyDeadlineType.toEntity(text: applyDeadlineType),
            applyDeadline: applyDeadline,
            payType: PaymentType.toEntity(text: payType),
            payAmount: formedPayAmount,
            distance: distance
        )
    }
}
