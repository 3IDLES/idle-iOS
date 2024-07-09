//
//  BusinessInfoDTO.swift
//  ConcreteRepository
//
//  Created by choijunios on 7/9/24.
//

import Foundation
import Entity

struct BusinessInfoDTO: Decodable {
    
    let businessRegistrationNumber: String
    let companyName: String
}

extension BusinessInfoDTO {
    
    func toEntity() -> BusinessInfoVO {
        
        return BusinessInfoVO(name: companyName)
    }
}
