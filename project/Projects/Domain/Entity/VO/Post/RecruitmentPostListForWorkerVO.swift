//
//  RecruitmentPostListForWorkerVO.swift
//  Entity
//
//  Created by choijunios on 8/16/24.
//

import Foundation

public class RecruitmentPostListForWorkerVO {

    public let posts: [RecruitmentPostForWorkerVO]
    public let nextPageId: String?
    public let fetchedPostCount: Int
    
    public init(posts: [RecruitmentPostForWorkerVO], nextPageId: String?, fetchedPostCount: Int) {
        self.posts = posts
        self.nextPageId = nextPageId
        self.fetchedPostCount = fetchedPostCount
    }
}

public class RecruitmentPostForWorkerVO {
    public let postId: String
    
    public let weekdays: [WorkDay]
    public let startTime: String
    public let endTime: String
    
    public let roadNameAddress: String
    public let lotNumberAddress: String
    
    public let gender: Gender
    public let age: Int
    public let careLevel: CareGrade
    
    public let isExperiencePreferred: Bool
    public let applyDeadlineType: ApplyDeadlineType
    public let applyDeadline: String?
    public let payType: PaymentType
    public let payAmount: String
    
    public let distance: Int
    
    public init(
        postId: String,
        weekdays: [WorkDay],
        startTime: String,
        endTime: String,
        roadNameAddress: String,
        lotNumberAddress: String,
        gender: Gender,
        age: Int,
        careLevel: CareGrade,
        isExperiencePreferred: Bool,
        applyDeadlineType: ApplyDeadlineType,
        applyDeadline: String?,
        payType: PaymentType,
        payAmount: String,
        distance: Int
    ) {
        self.postId = postId
        self.weekdays = weekdays
        self.startTime = startTime
        self.endTime = endTime
        self.roadNameAddress = roadNameAddress
        self.lotNumberAddress = lotNumberAddress
        self.gender = gender
        self.age = age
        self.careLevel = careLevel
        self.isExperiencePreferred = isExperiencePreferred
        self.applyDeadlineType = applyDeadlineType
        self.applyDeadline = applyDeadline
        self.payType = payType
        self.payAmount = payAmount
        self.distance = distance
    }
}
