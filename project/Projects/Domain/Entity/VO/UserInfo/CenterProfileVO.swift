//
//  CenterProfileVO.swift
//  Entity
//
//  Created by choijunios on 7/20/24.
//

import Foundation

public class CenterProfileVO: Codable {
    public let centerName: String
    public let officeNumber: String
    public let roadNameAddress: String
    public let lotNumberAddress: String
    public let detailedAddress: String
    public let longitude: String
    public let latitude: String
    public let introduce: String
    public let profileImageURL: URL?
    
    public init(centerName: String, officeNumber: String, roadNameAddress: String, lotNumberAddress: String, detailedAddress: String, longitude: String, latitude: String, introduce: String, profileImageURL: URL?) {
        self.centerName = centerName
        self.officeNumber = officeNumber
        self.roadNameAddress = roadNameAddress
        self.lotNumberAddress = lotNumberAddress
        self.detailedAddress = detailedAddress
        self.longitude = longitude
        self.latitude = latitude
        self.introduce = introduce
        self.profileImageURL = profileImageURL
    }
}
