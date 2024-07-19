//
//  WorkerEmployCardVO.swift
//  Entity
//
//  Created by choijunios on 7/19/24.
//

import Foundation

public enum Day: String {
    case mon = "월"
    case tue = "화"
    case wed = "수"
    case thu = "목"
    case fri = "금"
    case sat = "터"
    case sun = "일"
    
    static let days: [Day] = [
        mon,
        tue,
        wed,
        thu,
        fri,
    ]
}

public struct WorkerEmployCardVO {
    
    public let dayLeft: Int
    public let isBeginnerPossible: Bool
    public let title: String
    public let timeTakenForWalk: String
    public let targetAge: Int
    public let targetLevel: Int
    public let targetGender: Gender
    public let days: [Day]
    public let startTime: String
    public let endTime: String
    public let payPerHour: String
}

public extension WorkerEmployCardVO {
    
    static let mock = WorkerEmployCardVO(
        dayLeft: 10,
        isBeginnerPossible: true,
        title: "서울특별시 강남구 신사동",
        timeTakenForWalk: "도보 15분~20분",
        targetAge: 78,
        targetLevel: 1,
        targetGender: .female,
        days: Day.days,
        startTime: "09:00",
        endTime: "15:00",
        payPerHour: "12,500"
    )
}
