//
//  RecruitmentPostListForCenterDTO.swift
//  DataSource
//
//  Created by choijunios on 8/27/24.
//

import Foundation
import Domain

public struct RecruitmentPostForCenterListDTO: Decodable {
    public let jobPostings: [RecruitmentPostForCenterDTO]
}

public struct RecruitmentPostForCenterDTO: Decodable {
    public let id: String
    public let roadNameAddress: String
    public let lotNumberAddress: String
    public let clientName: String
    public let gender: String
    public let age: Int
    public let careLevel: Int
    public let applyDeadlineType: String
    public let applyDeadline: String?
    public let createdAt: String
    
    public func toVO() -> RecruitmentPostInfoForCenterVO {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let applyDeadline = self.applyDeadline != nil ? dateFormatter.date(from: applyDeadline!) : nil
        let createdAt = dateFormatter.date(from: self.createdAt)!
        
        return .init(
            id: id,
            roadNameAddress: roadNameAddress,
            lotNumberAddress: lotNumberAddress,
            clientName: clientName,
            gender: Gender.toEntity(text: gender),
            age: age,
            careLevel: CareGrade(rawValue: careLevel-1)!,
            applyDeadlineType: ApplyDeadlineType.toEntity(text: applyDeadlineType),
            applyDeadline: applyDeadline,
            createdAt: createdAt
        )
    }
}
