//
//  WorkerEmployCardVO.swift
//  Entity
//
//  Created by choijunios on 7/19/24.
//

import Foundation

public struct WorkerEmployCardVO {
    
    public let postId: String
    public let dayLeft: Int
    public let isBeginnerPossible: Bool
    public let timeTakenForWalk: String
    public let title: String
    public let targetAge: Int
    public let careGrade: CareGrade
    public let targetGender: Gender
    public let days: [WorkDay]
    public let startTime: String
    public let endTime: String
    public let paymentType: PaymentType
    public let paymentAmount: Int
    
    public init(postId: String, dayLeft: Int, isBeginnerPossible: Bool, timeTakenForWalk: String, title: String, targetAge: Int, careGrade: CareGrade, targetGender: Gender, days: [WorkDay], startTime: String, endTime: String, paymentType: PaymentType, paymentAmount: Int) {
        self.postId = postId
        self.dayLeft = dayLeft
        self.isBeginnerPossible = isBeginnerPossible
        self.timeTakenForWalk = timeTakenForWalk
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
      
    public static func create(
        postId: String,
        workTimeAndPay: WorkTimeAndPayStateObject,
        customerRequirement: CustomerRequirementStateObject,
        customerInformation: CustomerInformationStateObject,
        applicationDetail: ApplicationDetailStateObject,
        addressInfo: AddressInputStateObject
    ) -> WorkerEmployCardVO {
        
        // 남은 일수
        var leftDay: Int? = nil
        let calendar = Calendar.current
        let currentDate = Date()
        
        if applicationDetail.applyDeadlineType == .specificDate, let deadlineDate = applicationDetail.deadlineDate {
            
            let component = calendar.dateComponents([.day], from: currentDate, to: deadlineDate)
            leftDay = component.day
        }
        
        // 초보가능 여부
        let isBeginnerPossible = applicationDetail.experiencePreferenceType == .beginnerPossible
        
        // 제목(=도로명주소)
        let title = addressInfo.addressInfo?.roadAddress.emptyDefault("위치정보 표기 오류") ?? ""
        
        // 도보시간
        let timeTakenForWalk = "도보 n분"
        
        // 생년
        let birthYear = Int(customerInformation.birthYear) ?? 1950
        let currentYear = calendar.component(.year, from: currentDate)
        let targetAge = currentYear - birthYear + 1
        
        // 요양등급
        let careGrade: CareGrade = customerInformation.careGrade ?? .one
        
        // 성별
        let targetGender = customerInformation.gender
        
        // 근무 요일
        let days = workTimeAndPay.selectedDays.filter { (_, value) in
            value
        }.map { (key, _) in key }
        
        // 근무 시작, 종료시간
        let startTime = workTimeAndPay.workStartTime?.convertToStringForButton() ?? "00:00"
        let workEndTime = workTimeAndPay.workEndTime?.convertToStringForButton() ?? "00:00"
        
        // 급여타입및 양
        let paymentType = workTimeAndPay.paymentType ?? .hourly
        let paymentAmount = Int(workTimeAndPay.paymentAmount) ?? 0
        
        return WorkerEmployCardVO(
            postId: postId,
            dayLeft: leftDay ?? 0,
            isBeginnerPossible: isBeginnerPossible,
            timeTakenForWalk: timeTakenForWalk,
            title: title,
            targetAge: targetAge,
            careGrade: careGrade,
            targetGender: targetGender ?? .notDetermined,
            days: days,
            startTime: startTime,
            endTime: workEndTime,
            paymentType: paymentType,
            paymentAmount: paymentAmount
        )
    }
}


fileprivate extension String {
    
    func emptyDefault(_ str: String) -> String {
        self.isEmpty ? str : self
    }
}

public extension WorkerEmployCardVO {
    
    static let mock = WorkerEmployCardVO(
        postId: "00-00000-00000",
        dayLeft: 10,
        isBeginnerPossible: true,
        timeTakenForWalk: "도보 15분",
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
        postId: "00-00000-00000",
        dayLeft: 0,
        isBeginnerPossible: true,
        timeTakenForWalk: "도보 15분",
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
