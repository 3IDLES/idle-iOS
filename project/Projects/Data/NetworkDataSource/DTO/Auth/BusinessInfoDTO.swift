//
//  BusinessInfoDTO.swift
//  ConcreteRepository
//
//  Created by choijunios on 7/9/24.
//

import Foundation
import Entity

public struct BusinessInfoDTO: Decodable {
    
    public let businessRegistrationNumber: String
    public let companyName: String
}

public extension BusinessInfoDTO {
    
    func toEntity() -> BusinessInfoVO {
        
        return BusinessInfoVO(name: companyName)
    }
}
