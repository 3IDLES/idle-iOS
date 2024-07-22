//
//  WorkerProfileVO.swift
//  Entity
//
//  Created by choijunios on 7/22/24.
//

import Foundation

public struct WorkerProfileVO {
    
    public let profileImageURL: URL?
    
    
    public let nameText: String
    public let isLookingForJob: Bool
    public let ageText: String
    public let genderText: String
    public let expYearText: String
    public let addressText: String
    public let introductionText: String
    public let abilitiesText: String
    
    public init(profileImageURL: URL?, nameText: String, isLookingForJob: Bool, ageText: String, genderText: String, expYearText: String, addressText: String, introductionText: String, abilitiesText: String) {
        self.profileImageURL = profileImageURL
        self.nameText = nameText
        self.isLookingForJob = isLookingForJob
        self.ageText = ageText
        self.genderText = genderText
        self.expYearText = expYearText
        self.addressText = addressText
        self.introductionText = introductionText
        self.abilitiesText = abilitiesText
    }
}

public extension WorkerProfileVO {
    static let mock = WorkerProfileVO(
        profileImageURL: URL(string: "https://dummyimage.com/500x500/000/fff&text=worker+profile"),
        nameText: "홍갈동",
        isLookingForJob: true,
        ageText: "58세",
        genderText: Gender.female.twoLetterKoreanWord,
        expYearText: "1년차",
        addressText: "서울특별시 강남구 삼성동 512-3",
        introductionText: "안녕하세요 반갑습니다!",
        abilitiesText: "말동무 잘함"
    )
}
