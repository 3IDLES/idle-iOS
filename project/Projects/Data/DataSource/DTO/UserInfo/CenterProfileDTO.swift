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
            centerName: centerName,
            officeNumber: officeNumber,
            roadNameAddress: roadNameAddress,
            lotNumberAddress: lotNumberAddress,
            detailedAddress: detailedAddress,
            longitude: longitude ?? "",
            latitude: latitude ?? "",
            introduce: introduce ?? "",
            profileImageInfo: imageInfo
        )
    }
}
