//
//  RecruitmentPostDTO.swift
//  ConcreteRepository
//
//  Created by choijunios on 8/8/24.
//

import Foundation
import Entity

public struct RecruitmentPostDTO: Codable {
    public let isMealAssistance, isBowelAssistance, isWalkingAssistance, isExperiencePreferred: Bool
    public let weekdays: [String]
    public let startTime, endTime, payType: String
    public let payAmount: Int
    public let roadNameAddress, lotNumberAddress, clientName, gender: String
    public let birthYear: Int
    public let weight: Int?
    public let careLevel: Int
    public let mentalStatus: String
    public let disease: String?
    public let lifeAssistance: [String]?
    public let extraRequirement: String?
    public let applyMethod: [String]
    public let applyDeadline: String
    public let applyDeadlineType: String
    
    public init(isMealAssistance: Bool, isBowelAssistance: Bool, isWalkingAssistance: Bool, isExperiencePreferred: Bool, weekdays: [String], startTime: String, endTime: String, payType: String, payAmount: Int, roadNameAddress: String, lotNumberAddress: String, clientName: String, gender: String, birthYear: Int, weight: Int?, careLevel: Int, mentalStatus: String, disease: String?, lifeAssistance: [String]?, extraRequirement: String?, applyMethod: [String], applyDeadline: String, applyDeadlineType: String) {
        self.isMealAssistance = isMealAssistance
        self.isBowelAssistance = isBowelAssistance
        self.isWalkingAssistance = isWalkingAssistance
        self.isExperiencePreferred = isExperiencePreferred
        self.weekdays = weekdays
        self.startTime = startTime
        self.endTime = endTime
        self.payType = payType
        self.payAmount = payAmount
        self.roadNameAddress = roadNameAddress
        self.lotNumberAddress = lotNumberAddress
        self.clientName = clientName
        self.gender = gender
        self.birthYear = birthYear
        self.weight = weight
        self.careLevel = careLevel
        self.mentalStatus = mentalStatus
        self.disease = disease
        self.lifeAssistance = lifeAssistance
        self.extraRequirement = extraRequirement
        self.applyMethod = applyMethod
        self.applyDeadline = applyDeadline
        self.applyDeadlineType = applyDeadlineType
    }
}
