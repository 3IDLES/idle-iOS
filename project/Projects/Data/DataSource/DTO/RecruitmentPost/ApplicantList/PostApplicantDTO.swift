//
//  PostApplicantDTO.swift
//  DataSource
//
//  Created by choijunios on 8/29/24.
//

import Foundation
import Domain

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
        
        var imageInfo: ImageDownLoadInfo? = nil
        
        if let url = profileImageUrl, let expString = url.split(separator: ".").last {
            
            let imageFormat = expString.uppercased()
            
            if let format = ImageFormat(rawValue: imageFormat) {
                    
                imageInfo = .init(
                    imageURL: URL(string: url)!,
                    imageFormat: format
                )
            }
        }
        
        return .init(
            workerId: carerId,
            imageInfo: imageInfo,
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
