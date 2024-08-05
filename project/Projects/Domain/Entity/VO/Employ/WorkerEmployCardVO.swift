//
//  WorkerEmployCardVO.swift
//  Entity
//
//  Created by choijunios on 7/19/24.
//

import Foundation

public struct WorkerEmployCardVO {
    
    public let dayLeft: Int
    public let isBeginnerPossible: Bool
    public let title: String
    public let timeTakenForWalk: String
    public let targetAge: Int
    public let targetLevel: Int
    public let targetGender: Gender
    public let days: [WorkDay]
    public let startTime: String
    public let endTime: String
    public let paymentType: PaymentType
    public let paymentAmount: String
    
    public init(dayLeft: Int, isBeginnerPossible: Bool, title: String, timeTakenForWalk: String, targetAge: Int, targetLevel: Int, targetGender: Gender, days: [WorkDay], startTime: String, endTime: String, paymentType: PaymentType, paymentAmount: String) {
        self.dayLeft = dayLeft
        self.isBeginnerPossible = isBeginnerPossible
        self.title = title
        self.timeTakenForWalk = timeTakenForWalk
        self.targetAge = targetAge
        self.targetLevel = targetLevel
        self.targetGender = targetGender
        self.days = days
        self.startTime = startTime
        self.endTime = endTime
        self.paymentType = paymentType
        self.paymentAmount = paymentAmount
    }
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
        days: WorkDay.allCases,
        startTime: "09:00",
        endTime: "15:00",
        paymentType: .monthly,
        paymentAmount: "12,500"
    )
}
