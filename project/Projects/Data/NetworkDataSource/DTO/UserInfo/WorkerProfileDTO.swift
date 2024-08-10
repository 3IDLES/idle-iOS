//
//  WorkerProfileDTO.swift
//  NetworkDataSource
//
//  Created by choijunios on 8/10/24.
//

import Foundation
import Entity

public struct CarerProfileDTO: Codable {
    let carerName: String
    let age: Int
    let gender: String
    let experienceYear: Int?
    let phoneNumber: String
    let roadNameAddress: String
    let lotNumberAddress: String
    let introduce: String?
    let speciality: String?
    let profileImageUrl: String?
    let jobSearchStatus: String
    
    
    public func toVO() -> WorkerProfileVO {
        
        return .init(
            profileImageURL: profileImageUrl,
            nameText: carerName,
            phoneNumber: phoneNumber,
            isLookingForJob: jobSearchStatus == "YES",
            age: age,
            gender: gender == "MAN" ? .male : .female,
            expYear: experienceYear,
            address: .init(
                roadAddress: roadNameAddress,
                jibunAddress: lotNumberAddress
            ),
            introductionText: introduce ?? "",
            specialty: speciality ?? ""
        )
    }
}
