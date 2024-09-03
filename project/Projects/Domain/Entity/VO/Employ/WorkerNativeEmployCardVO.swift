//
//  WorkerNativeEmployCardVO.swift
//  Entity
//
//  Created by choijunios on 7/19/24.
//

import Foundation

public struct WorkerNativeEmployCardVO {
    
    public let dayLeft: Int
    public let isBeginnerPossible: Bool
    public let distanceFromWorkPlace: Int
    public let title: String
    public let targetAge: Int
    public let careGrade: CareGrade
    public let targetGender: Gender
    public let days: [WorkDay]
    public let startTime: String
    public let endTime: String
    public let paymentType: PaymentType
    public let paymentAmount: String
    public let applyDate: Date?
    public let isFavorite: Bool
    
    public init(
        dayLeft: Int,
        isBeginnerPossible: Bool,
        distanceFromWorkPlace: Int,
        title: String,
        targetAge: Int,
        careGrade: CareGrade,
        targetGender: Gender,
        days: [WorkDay],
        startTime: String,
        endTime: String,
        paymentType: PaymentType,
        paymentAmount: String,
        applyDate: Date?,
        isFavorite: Bool
    ) {
        self.dayLeft = dayLeft
        self.isBeginnerPossible = isBeginnerPossible
        self.distanceFromWorkPlace = distanceFromWorkPlace
        self.title = title
        self.targetAge = targetAge
        self.careGrade = careGrade
        self.targetGender = targetGender
        self.days = days
        self.startTime = startTime
        self.endTime = endTime
        self.paymentType = paymentType
        self.paymentAmount = paymentAmount
        self.applyDate = applyDate
        self.isFavorite = isFavorite
    }
      
    /// 공고 상세화면에서 사용됩니다.
    public static func create(
        workTimeAndPay: WorkTimeAndPayStateObject,
        customerRequirement: CustomerRequirementStateObject,
        customerInformation: CustomerInformationStateObject,
        applicationDetail: ApplicationDetailStateObject,
        addressInfo: AddressInputStateObject
    ) -> WorkerNativeEmployCardVO {
        
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
        let paymentAmount = workTimeAndPay.paymentAmount
        
        return WorkerNativeEmployCardVO(
            dayLeft: leftDay ?? 31,
            isBeginnerPossible: isBeginnerPossible,
            distanceFromWorkPlace: 500,
            title: title,
            targetAge: targetAge,
            careGrade: careGrade,
            targetGender: targetGender ?? .notDetermined,
            days: days,
            startTime: startTime,
            endTime: workEndTime,
            paymentType: paymentType,
            paymentAmount: paymentAmount,
            applyDate: nil,
            isFavorite: false
        )
    }
    
    public static func create(vo: NativeRecruitmentPostForWorkerVO) -> WorkerNativeEmployCardVO {
        
        // 남은 일수
        var leftDay: Int? = nil
        let calendar = Calendar.current
        let currentDate = Date()
        
        if vo.applyDeadlineType == .specificDate, let deadlineDate = vo.applyDeadlineDate {
            
            let component = calendar.dateComponents([.day], from: currentDate, to: deadlineDate)
            leftDay = component.day
        }
        
        return .init(
            dayLeft: leftDay ?? 31,
            isBeginnerPossible: !vo.isExperiencePreferred,
            distanceFromWorkPlace: vo.distanceFromWorkPlace,
            title: vo.roadNameAddress,
            targetAge: vo.age,
            careGrade: vo.cardGrade,
            targetGender: vo.gender,
            days: vo.workDays,
            startTime: vo.startTime,
            endTime: vo.endTime,
            paymentType: vo.payType,
            paymentAmount: vo.payAmount,
            applyDate: vo.applyTime,
            isFavorite: vo.isFavorite
        )
    }
}


fileprivate extension String {
    
    func emptyDefault(_ str: String) -> String {
        self.isEmpty ? str : self
    }
}

public extension WorkerNativeEmployCardVO {
    
    static let mock: WorkerNativeEmployCardVO = .init(
        dayLeft: 10,
        isBeginnerPossible: true,
        distanceFromWorkPlace: 500,
        title: "서울특별시 강남구 신사동",
        targetAge: 78,
        careGrade: .four,
        targetGender: .female,
        days: WorkDay.allCases,
        startTime: "09:00",
        endTime: "15:00",
        paymentType: .hourly,
        paymentAmount: "12,500",
        applyDate: nil,
        isFavorite: false
    )
    
    static let `default`: WorkerNativeEmployCardVO = .init(
        dayLeft: 0,
        isBeginnerPossible: true,
        distanceFromWorkPlace: 8000,
        title: "기본값",
        targetAge: 10,
        careGrade: .one,
        targetGender: .notDetermined,
        days: [],
        startTime: "00:00",
        endTime: "00:00",
        paymentType: .hourly,
        paymentAmount: "12,500",
        applyDate: nil,
        isFavorite: false
    )
}
