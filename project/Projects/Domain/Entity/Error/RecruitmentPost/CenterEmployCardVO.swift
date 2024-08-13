//
//  CenterEmployCardVO.swift
//  Entity
//
//  Created by choijunios on 8/13/24.
//

import Foundation

public class CenterEmployCardVO {
    
    public let postId: String
    public let isOngoing: Bool
    
    // For rendering
    public let startDay: String
    public let endDay: String?
    public let postTitle: String
    public let name: String
    public let careGrade: CareGrade
    public let age: Int
    public let gender: Gender
    public let applicantCount: Int
    
    public init(
        isOngoing: Bool,
        postId: String,
        startDay: String,
        endDay: String?,
        postTitle: String,
        name: String,
        careGrade: CareGrade,
        age: Int,
        gender: Gender,
        applicantCount: Int
    ) {
        self.isOngoing = isOngoing
        self.postId = postId
        self.startDay = startDay
        self.endDay = endDay
        self.postTitle = postTitle
        self.name = name
        self.careGrade = careGrade
        self.age = age
        self.gender = gender
        self.applicantCount = applicantCount
    }
    
    public static var mock: CenterEmployCardVO {
        .init(
            isOngoing: true,
            postId: "00-00000-00000",
            startDay: "12:00",
            endDay: nil,
            postTitle: "서울특별시 강남구 신사동",
            name: "홍길동",
            careGrade: .one,
            age: 78,
            gender: .female,
            applicantCount: 78
        )
    }
}
