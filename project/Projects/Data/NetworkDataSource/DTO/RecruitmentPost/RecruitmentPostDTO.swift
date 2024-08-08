//
//  RecruitmentPostDTO.swift
//  ConcreteRepository
//
//  Created by choijunios on 8/8/24.
//

import Foundation

public struct RecruitmentPostDTO: Codable {
    public let isMealAssistance, isBowelAssistance, isWalkingAssistance, isExperiencePreferred: Bool
    public let weekdays: [String]
    public let startTime, endTime, payType: String
    public let payAmount: Int
    public let roadNameAddress, lotNumberAddress, clientName, gender: String
    public let birthYear, weight, careLevel: Int
    public let mentalStatus, disease: String
    public let lifeAssistance: [String]
    public let speciality: String
    public let applyMethod: [String]
    public let applyDeadline, applyDeadlineType: String
    
    public init(isMealAssistance: Bool, isBowelAssistance: Bool, isWalkingAssistance: Bool, isExperiencePreferred: Bool, weekdays: [String], startTime: String, endTime: String, payType: String, payAmount: Int, roadNameAddress: String, lotNumberAddress: String, clientName: String, gender: String, birthYear: Int, weight: Int, careLevel: Int, mentalStatus: String, disease: String, lifeAssistance: [String], speciality: String, applyMethod: [String], applyDeadline: String, applyDeadlineType: String) {
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
        self.speciality = speciality
        self.applyMethod = applyMethod
        self.applyDeadline = applyDeadline
        self.applyDeadlineType = applyDeadlineType
    }
}
