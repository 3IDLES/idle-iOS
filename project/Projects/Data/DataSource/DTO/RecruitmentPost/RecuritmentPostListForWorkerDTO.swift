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
    public let total: Int
    
    public func toEntity() -> RecruitmentPostListForWorkerVO {
        
        return .init(
            posts: items.map { $0.toEntity() },
            nextPageId: next,
            fetchedPostCount: total
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
        
        let workDayList = weekdays.map({ dayText in
            WorkDay.toEntity(text: dayText)
        })
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let deadlineDate = applyDeadline != nil ? dateFormatter.date(from: applyDeadline!) : nil
        
        return .init(
            postId: id,
            workDays: workDayList,
            startTime: startTime,
            endTime: endTime,
            roadNameAddress: roadNameAddress,
            lotNumberAddress: lotNumberAddress,
            gender: Gender.toEntity(text: gender),
            age: age,
            cardGrade: CareGrade(rawValue: careLevel-1)!,
            isExperiencePreferred: isExperiencePreferred,
            applyDeadlineType: ApplyDeadlineType.toEntity(text: applyDeadlineType),
            applyDeadlineDate: deadlineDate,
            payType: PaymentType.toEntity(text: payType),
            payAmount: String(payAmount),
            distanceFromWorkPlace: String(distance)
        )
    }
}
