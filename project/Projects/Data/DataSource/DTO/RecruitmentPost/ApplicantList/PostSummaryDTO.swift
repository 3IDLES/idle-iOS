//
//  PostSummaryDTO.swift
//  DataSource
//
//  Created by choijunios on 8/29/24.
//

import Foundation
import Domain

public struct PostApplicantScreenDTO: Codable {
    public let jobPostingSummaryDto: PostSummaryDTO
    public let jobPostingApplicants: [PostApplicantDTO]
    
    public func toVO() -> PostApplicantScreenVO {
         
        let summaryCardVO = jobPostingSummaryDto.toVO()
        let applicantList = jobPostingApplicants.map { $0.toVO() }
        
        return (summaryCardVO: summaryCardVO, applicantList: applicantList)
    }
}

public struct PostSummaryDTO: Codable {
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
    
    public func toVO() -> CenterEmployCardVO {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let startDayDate = dateFormatter.date(from: createdAt)!
        let deadLineDate = applyDeadline != nil ? dateFormatter.date(from: applyDeadline!) : nil
        
        return .init(
            postId: id,
            startDay: startDayDate,
            endDay: deadLineDate,
            roadNameAddress: roadNameAddress,
            name: clientName,
            careGrade: CareGrade(rawValue: careLevel-1)!,
            age: age,
            gender: Gender.toEntity(text: gender)
        )
    }
}
