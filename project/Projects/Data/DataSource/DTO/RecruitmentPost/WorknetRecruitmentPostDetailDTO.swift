//
//  WorknetRecruitmentPostDetailDTO.swift
//  DataSource
//
//  Created by choijunios on 9/6/24.
//

import Foundation
import Domain

public struct WorknetRecruitmentPostDetailDTO: EntityRepresentable {
    
    let id: String
    let title: String
    let content: String
    let clientAddress: String
    let longitude: String?
    let latitude: String?
    let distance: Int
    let createdAt: String
    let payInfo: String
    let workingTime: String
    let workingSchedule: String
    let applyDeadline: String
    let recruitmentProcess: String
    let applyMethod: String
    let requiredDocumentation: String
    let centerName: String
    let centerAddress: String
    let jobPostingUrl: String
    let jobPostingType: RecruitmentPostType
    let isFavorite: Bool
    
    public func toEntity() -> WorknetRecruitmentPostDetailVO {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let createdAtDate = dateFormatter.date(from: createdAt) ?? Date()
        let applyDeadlineDate = dateFormatter.date(from: applyDeadline) ?? Date()
        
        return .init(
            id: id,
            title: title,
            content: content,
            clientAddress: clientAddress,
            longitude: longitude,
            latitude: latitude,
            distance: distance,
            createdAt: createdAtDate,
            payInfo: payInfo,
            workingTime: workingTime,
            workingSchedule: workingSchedule,
            applyDeadline: applyDeadlineDate,
            recruitmentProcess: recruitmentProcess,
            applyMethod: applyMethod,
            requiredDocumentation: requiredDocumentation,
            centerName: centerName,
            centerAddress: centerAddress,
            jobPostingUrl: jobPostingUrl,
            jobPostingType: jobPostingType,
            isFavorite: isFavorite
        )
    }
}
