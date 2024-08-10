//
//  WorkerProfileVO.swift
//  Entity
//
//  Created by choijunios on 7/22/24.
//

import Foundation

public struct WorkerProfileVO {
    
    public let profileImageURL: String?
    
    
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
        profileImageURL: String?,
        nameText: String,
        phoneNumber: String,
        isLookingForJob: Bool,
        age: Int,
        gender: Gender,
        expYear: Int?,
        address: AddressInformation,
        introductionText: String,
        specialty: String
    ) {
        self.profileImageURL = profileImageURL
        self.nameText = nameText
        self.phoneNumber = phoneNumber
        self.isLookingForJob = isLookingForJob
        self.age = age
        self.gender = gender
        self.expYear = expYear
        self.address = address
        self.introductionText = introductionText
        self.specialty = specialty
    }
}

public extension WorkerProfileVO {
    static let mock: WorkerProfileVO = .init(
        profileImageURL: nil,
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
        specialty: ""
    )
}
