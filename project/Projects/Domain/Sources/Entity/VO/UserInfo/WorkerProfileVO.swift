//
//  WorkerProfileVO.swift
//  Entity
//
//  Created by choijunios on 7/22/24.
//

import Foundation

public struct WorkerProfileVO: Codable {
    
    public let profileImageInfo: ImageDownLoadInfo?
    public let longitude: Double
    public let latitude: Double
    public let nameText: String
    public let phoneNumber: String
    public let isLookingForJob: Bool
    public let age: Int
    public let gender: Gender
    public let expYear: Int?
    public let address: AddressInformation
    public let introductionText: String
    public let specialty: String
    
    public init(
        profileImageInfo: ImageDownLoadInfo?,
        nameText: String,
        phoneNumber: String,
        isLookingForJob: Bool,
        age: Int,
        gender: Gender,
        expYear: Int?,
        address: AddressInformation,
        introductionText: String,
        specialty: String,
        longitude: Double,
        latitude: Double
    ) {
        self.profileImageInfo = profileImageInfo
        self.nameText = nameText
        self.phoneNumber = phoneNumber
        self.isLookingForJob = isLookingForJob
        self.age = age
        self.gender = gender
        self.expYear = expYear
        self.address = address
        self.introductionText = introductionText
        self.specialty = specialty
        self.latitude = latitude
        self.longitude = longitude
    }
}

public extension WorkerProfileVO {
    static let mock: WorkerProfileVO = .init(
        profileImageInfo: nil,
        nameText: "",
        phoneNumber: "",
        isLookingForJob: true,
        age: 58,
        gender: .female,
        expYear: nil,
        address: .init(
            roadAddress: "",
            jibunAddress: ""
        ),
        introductionText: "",
        specialty: "",
        longitude: 0.0,
        latitude: 0.0
    )
}
