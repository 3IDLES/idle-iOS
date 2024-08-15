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
    public let targetAge: Int
    public let careGrade: CareGrade
    public let targetGender: Gender
    public let days: [WorkDay]
    public let startTime: String
    public let endTime: String
    public let paymentType: PaymentType
    public let paymentAmount: Int
    
    public init(dayLeft: Int, isBeginnerPossible: Bool, title: String, targetAge: Int, careGrade: CareGrade, targetGender: Gender, days: [WorkDay], startTime: String, endTime: String, paymentType: PaymentType, paymentAmount: Int) {
        self.dayLeft = dayLeft
        self.isBeginnerPossible = isBeginnerPossible
        self.title = title
        self.targetAge = targetAge
        self.careGrade = careGrade
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
        targetAge: 78,
        careGrade: .four,
        targetGender: .female,
        days: WorkDay.allCases,
        startTime: "09:00",
        endTime: "15:00",
        paymentType: .hourly,
        paymentAmount: 12500
    )
    
    static let `default` = WorkerEmployCardVO(
        dayLeft: 0,
        isBeginnerPossible: true,
        title: "기본값",
        targetAge: 10,
        careGrade: .one,
        targetGender: .notDetermined,
        days: [],
        startTime: "00:00",
        endTime: "00:00",
        paymentType: .hourly,
        paymentAmount: 0
    )
}
