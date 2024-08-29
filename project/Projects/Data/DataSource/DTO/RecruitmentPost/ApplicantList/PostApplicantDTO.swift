//
//  PostApplicantDTO.swift
//  DataSource
//
//  Created by choijunios on 8/29/24.
//

import Foundation
import Entity

public struct PostApplicantDTO: Codable {
    public let carerId: String
    public let name: String
    public let age: Int
    public let gender: String
    public let experienceYear: Int?
    public let profileImageUrl: String?
    /// YES
    public let jobSearchStatus: String
    
    public func toVO() -> PostApplicantVO {
        
        var profileUrl: URL?
        if let profileImageUrl {
            profileUrl = URL(string: profileImageUrl)
        }
        
        return .init(
            workerId: carerId,
            profileUrl: profileUrl,
            isJobFinding: jobSearchStatus == "YES",
            
            // MARK:  센터가 즐겨찾기하는 요양보호사 추후 개발예정
            isStared: false,
            name: name,
            age: age,
            gender: Gender.toEntity(text: gender),
            expYear: experienceYear
        )
    }
}
