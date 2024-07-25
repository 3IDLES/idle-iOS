//
//  WorkerRegistrationDTO.swift
//  NetworkDataSource
//
//  Created by choijunios on 7/24/24.
//

import Foundation
import Entity

public struct WorkerRegistrationDTO: Encodable {
    public let carerName: String
    public let birthYear: Int
    public let genderType: String
    public let phoneNumber: String
    public let roadNameAddress: String
    public let lotNumberAddress: String
    public let longitude: String
    public let latitude: String
    
    public init(carerName: String, birthYear: Int, genderType: Gender, phoneNumber: String, roadNameAddress: String, lotNumberAddress: String, longitude: String, latitude: String) {
        self.carerName = carerName
        self.birthYear = birthYear
        self.genderType = Self.convertGenderValue(genderType)
        self.phoneNumber = phoneNumber
        self.roadNameAddress = roadNameAddress
        self.lotNumberAddress = lotNumberAddress
        self.longitude = longitude
        self.latitude = latitude
    }
}

public extension WorkerRegistrationDTO {
    
    static func convertGenderValue(_ gender: Gender) -> String {
        
        if gender == .notDetermined { fatalError() }
        return gender == .male ? "MAN" : "WOMAN"
    }
}
