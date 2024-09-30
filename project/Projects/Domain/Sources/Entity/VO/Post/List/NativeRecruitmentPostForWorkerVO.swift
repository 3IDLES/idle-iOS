//
//  NativeRecruitmentPostForWorkerVO.swift
//  Entity
//
//  Created by choijunios on 8/16/24.
//

import Foundation

public struct NativeRecruitmentPostForWorkerVO: RecruitmentPostForWorkerRepresentable {
    
    // protocol required
    public var postType: RecruitmentPostType
    public var beFavoritedTime: Date?
    
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
    
    public let distanceFromWorkPlace: Int
    public let applyTime: Date?
    public let isFavorite: Bool
    
    
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
        distanceFromWorkPlace: Int,
        applyTime: Date?,
        isFavorite: Bool,
        postType: RecruitmentPostType,
        beFavoritedTime: Date?
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
        self.applyTime = applyTime
        self.isFavorite = isFavorite
        self.postType = postType
        self.beFavoritedTime = beFavoritedTime
    }
    
    public static let mock = NativeRecruitmentPostForWorkerVO(
        postId: "test-post-id",
        workDays: [.mon, .wed, .fri],
        startTime: "09:00",
        endTime: "17:00",
        roadNameAddress: "서울시 영등포구 여등포동",
        lotNumberAddress: "서울시 영등포구 여등포동",
        gender: .female,
        age: 54,
        cardGrade: .three,
        isExperiencePreferred: true,
        applyDeadlineType: .specificDate,
        applyDeadlineDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()),
        payType: .hourly,
        payAmount: "15000",
        distanceFromWorkPlace: 2500,
        applyTime: Date(),
        isFavorite: true,
        postType: .native,
        beFavoritedTime: Calendar.current.date(byAdding: .day, value: 7, to: Date())
    )
}
