//
//  PostApplicantVO.swift
//  Entity
//
//  Created by choijunios on 8/13/24.
//

import Foundation

public struct PostApplicantVO {
    
    //
    public let workerId: String
    
    // For Render
    public let profileUrl: URL?
    public let isJobFinding: Bool
    public let isStared: Bool
    public let name: String
    public let age: Int
    public let gender: Gender
    public let expYear: Int?
    
    public init(workerId: String, profileUrl: URL?, isJobFinding: Bool, isStared: Bool, name: String, age: Int, gender: Gender, expYear: Int?) {
        self.workerId = workerId
        self.profileUrl = profileUrl
        self.isJobFinding = isJobFinding
        self.isStared = isStared
        self.name = name
        self.age = age
        self.gender = gender
        self.expYear = expYear
    }
    
    public static let mock: PostApplicantVO = .init(
        workerId: "testworkerId",
        profileUrl: URL(string: "https://dummyimage.com/600x400/00ffbf/0011ff&text=worker+profile"),
        isJobFinding: false,
        isStared: false,
        name: "홍길동",
        age: 51,
        gender: .female,
        expYear: nil
    )
}
