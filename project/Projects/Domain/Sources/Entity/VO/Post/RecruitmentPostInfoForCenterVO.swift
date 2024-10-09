//
//  RecruitmentPostForCenterVO.swift
//  Entity
//
//  Created by choijunios on 8/27/24.
//

import Foundation

public enum PostState {
    case onGoing
    case closed
}

public class RecruitmentPostInfoForCenterVO {
    
    public let id: String
    public let roadNameAddress: String
    public let lotNumberAddress: String
    public let clientName: String
    public let gender: Gender
    public let age: Int
    public let careLevel: CareGrade
    public let applyDeadlineType: ApplyDeadlineType
    public let applyDeadline: Date?
    public let createdAt: Date
    
    // MARK: 마감된 공고인지?
    public var state: PostState?
    
    public init(id: String, roadNameAddress: String, lotNumberAddress: String, clientName: String, gender: Gender, age: Int, careLevel: CareGrade, applyDeadlineType: ApplyDeadlineType, applyDeadline: Date?, createdAt: Date) {
        self.id = id
        self.roadNameAddress = roadNameAddress
        self.lotNumberAddress = lotNumberAddress
        self.clientName = clientName
        self.gender = gender
        self.age = age
        self.careLevel = careLevel
        self.applyDeadlineType = applyDeadlineType
        self.applyDeadline = applyDeadline
        self.createdAt = createdAt
    }
    
    func setState(_ to: PostState) -> Self {
        state = to
        return self
    }
}
