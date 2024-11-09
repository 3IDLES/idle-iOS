//
//  PostApplicantVO.swift
//  Entity
//
//  Created by choijunios on 8/13/24.
//

import Foundation

public typealias PostApplicantScreenVO = (summaryCardVO: CenterEmployCardVO, applicantList: [PostApplicantVO])

public struct PostApplicantVO {
    
    //
    public let workerId: String
    
    // For Render
    public let imageInfo: ImageDownLoadInfo?
    public let isJobFinding: Bool
    public let isStared: Bool
    public let name: String
    public let age: Int
    public let gender: Gender
    public let expYear: Int?
    
    public init(workerId: String, imageInfo: ImageDownLoadInfo?, isJobFinding: Bool, isStared: Bool, name: String, age: Int, gender: Gender, expYear: Int?) {
        self.workerId = workerId
        self.imageInfo = imageInfo
        self.isJobFinding = isJobFinding
        self.isStared = isStared
        self.name = name
        self.age = age
        self.gender = gender
        self.expYear = expYear
    }
    
    public static let mock: PostApplicantVO = .init(
        workerId: "testworkerId",
        imageInfo: nil,
        isJobFinding: false,
        isStared: false,
        name: "홍길동",
        age: 51,
        gender: .female,
        expYear: nil
    )
}
