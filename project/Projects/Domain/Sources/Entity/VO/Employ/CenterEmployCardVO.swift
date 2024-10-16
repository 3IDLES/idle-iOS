//
//  CenterEmployCardVO.swift
//  Entity
//
//  Created by choijunios on 8/13/24.
//

import Foundation

public class CenterEmployCardVO {
    
    public let postId: String
    
    // For rendering
    public let startDay: Date
    public let endDay: Date?
    public let roadNameAddress: String
    public let name: String
    public let careGrade: CareGrade
    public let age: Int
    public let gender: Gender
    
    public init(
        postId: String,
        startDay: Date,
        endDay: Date?,
        roadNameAddress: String,
        name: String,
        careGrade: CareGrade,
        age: Int,
        gender: Gender
    ) {
        self.postId = postId
        self.startDay = startDay
        self.endDay = endDay
        self.roadNameAddress = roadNameAddress
        self.name = name
        self.careGrade = careGrade
        self.age = age
        self.gender = gender
    }
    
    public static var mock: CenterEmployCardVO {
        .init(
            postId: "00-00000-00000",
            startDay: Date(),
            endDay: nil,
            roadNameAddress: "서울특별시 강남구 신사동 1231-123",
            name: "홍길동",
            careGrade: .one,
            age: 78,
            gender: .female
        )
    }
}
