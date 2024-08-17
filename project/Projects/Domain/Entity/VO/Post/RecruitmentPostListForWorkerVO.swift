//
//  RecruitmentPostListForWorkerVO.swift
//  Entity
//
//  Created by choijunios on 8/16/24.
//

import Foundation

public struct RecruitmentPostListForWorkerVO {

    public let posts: [RecruitmentPostForWorkerVO]
    public let nextPageId: String?
    public let fetchedPostCount: Int
    
    public init(posts: [RecruitmentPostForWorkerVO], nextPageId: String?, fetchedPostCount: Int) {
        self.posts = posts
        self.nextPageId = nextPageId
        self.fetchedPostCount = fetchedPostCount
    }
}

public struct RecruitmentPostForWorkerVO {
    public let postId: String
    
    public let workDays: [WorkDay]
    public let startTime: String
    public let endTime: String
    
    public let roadNameAddress: String
    public let lotNumberAddress: String
    
    public let gender: Gender
    public let age: Int
    public let cardGrade: CareGrade
    
    public let isExperiencePreferred: Bool
    public let applyDeadlineType: ApplyDeadlineType
    public let applyDeadlineDate: Date?
    public let payType: PaymentType
    public let payAmount: String
    
    public let distanceFromWorkPlace: String
    
    public init(
        postId: String,
        workDays: [WorkDay],
        startTime: String,
        endTime: String,
        roadNameAddress: String,
        lotNumberAddress: String,
        gender: Gender,
        age: Int,
        cardGrade: CareGrade,
        isExperiencePreferred: Bool,
        applyDeadlineType: ApplyDeadlineType,
        applyDeadlineDate: Date?,
        payType: PaymentType,
        payAmount: String,
        distanceFromWorkPlace: String
    ) {
        self.postId = postId
        self.workDays = workDays
        self.startTime = startTime
        self.endTime = endTime
        self.roadNameAddress = roadNameAddress
        self.lotNumberAddress = lotNumberAddress
        self.gender = gender
        self.age = age
        self.cardGrade = cardGrade
        self.isExperiencePreferred = isExperiencePreferred
        self.applyDeadlineType = applyDeadlineType
        self.applyDeadlineDate = applyDeadlineDate
        self.payType = payType
        self.payAmount = payAmount
        self.distanceFromWorkPlace = distanceFromWorkPlace
    }
}
