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
    public let isLookingForJob: Bool
    public let age: Int
    public let gender: Gender
    public let expYear: Int?
    public let addressText: String
    public let introductionText: String
    public let specialty: String
    
    public init(profileImageURL: String?, nameText: String, isLookingForJob: Bool, age: Int, gender: Gender, expYear: Int?, addressText: String, introductionText: String, specialty: String) {
        self.profileImageURL = profileImageURL
        self.nameText = nameText
        self.isLookingForJob = isLookingForJob
        self.age = age
        self.gender = gender
        self.expYear = expYear
        self.addressText = addressText
        self.introductionText = introductionText
        self.specialty = specialty
    }
}

public extension WorkerProfileVO {
    static let mock: WorkerProfileVO = .init(
        profileImageURL: "https://dummyimage.com/500x500/000/fff&text=worker+profile",
        nameText: "홍갈동",
        isLookingForJob: true,
        age: 58,
        gender: .female,
        expYear: nil,
        addressText: "서울특별시 강남구 삼성동 512-3",
        introductionText: "안녕하세요 반갑습니다!",
        specialty: "말동무 잘함"
    )
}
