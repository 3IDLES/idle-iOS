//
//  RegisterCenterProfileDTO.swift
//  NetworkDataSource
//
//  Created by choijunios on 7/27/24.
//

import Foundation
import Domain

public struct RegisterCenterProfileDTO: Codable {
    public let centerName: String
    public let officeNumber: String
    public let roadNameAddress: String
    public let lotNumberAddress: String
    public let detailedAddress: String
    public let introduce: String
    
    public init(centerName: String, officeNumber: String, roadNameAddress: String, lotNumberAddress: String, detailedAddress: String, introduce: String) {
        self.centerName = centerName
        self.officeNumber = officeNumber
        self.roadNameAddress = roadNameAddress
        self.lotNumberAddress = lotNumberAddress
        self.detailedAddress = detailedAddress
        self.introduce = introduce
    }
}
