//
//  CenterProfileDTO.swift
//  NetworkDataSource
//
//  Created by choijunios on 7/20/24.
//

import Foundation
import Entity

public struct CenterProfileDTO: Codable {
    let centerName: String
    let officeNumber: String
    let roadNameAddress: String
    let lotNumberAddress: String
    let detailedAddress: String
    let introduce: String?
    let longitude: String?
    let latitude: String?
    let profileImageUrl: String?
}

public extension CenterProfileDTO {
    
    func toEntity() -> CenterProfileVO {
        CenterProfileVO(
            centerName: centerName,
            officeNumber: officeNumber,
            roadNameAddress: roadNameAddress,
            lotNumberAddress: lotNumberAddress,
            detailedAddress: detailedAddress,
            longitude: longitude ?? "",
            latitude: latitude ?? "",
            introduce: introduce ?? "",
            profileImageURL: URL(string: profileImageUrl ?? "")
        )
    }
}
