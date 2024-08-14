//
//  RecruitmentPostDTO.swift
//  ConcreteRepository
//
//  Created by choijunios on 8/8/24.
//

import Foundation
import Entity

public struct RecruitmentPostRegisterDTO: Codable {
    public let isMealAssistance, isBowelAssistance, isWalkingAssistance, isExperiencePreferred: Bool
    public let weekdays: [String]
    public let startTime, endTime, payType: String
    public let payAmount: Int
    public let roadNameAddress, lotNumberAddress, clientName, gender: String
    public let birthYear: Int
    public let weight: Int?
    public let careLevel: Int
    public let mentalStatus: String
    public let disease: String?
    public let lifeAssistance: [String]?
    public let extraRequirement: String?
    public let applyMethod: [String]
    public let applyDeadline: String
    public let applyDeadlineType: String
    
    public init(isMealAssistance: Bool, isBowelAssistance: Bool, isWalkingAssistance: Bool, isExperiencePreferred: Bool, weekdays: [String], startTime: String, endTime: String, payType: String, payAmount: Int, roadNameAddress: String, lotNumberAddress: String, clientName: String, gender: String, birthYear: Int, weight: Int?, careLevel: Int, mentalStatus: String, disease: String?, lifeAssistance: [String]?, extraRequirement: String?, applyMethod: [String], applyDeadline: String, applyDeadlineType: String) {
        self.isMealAssistance = isMealAssistance
        self.isBowelAssistance = isBowelAssistance
        self.isWalkingAssistance = isWalkingAssistance
        self.isExperiencePreferred = isExperiencePreferred
        self.weekdays = weekdays
        self.startTime = startTime
        self.endTime = endTime
        self.payType = payType
        self.payAmount = payAmount
        self.roadNameAddress = roadNameAddress
        self.lotNumberAddress = lotNumberAddress
        self.clientName = clientName
        self.gender = gender
        self.birthYear = birthYear
        self.weight = weight
        self.careLevel = careLevel
        self.mentalStatus = mentalStatus
        self.disease = disease
        self.lifeAssistance = lifeAssistance
        self.extraRequirement = extraRequirement
        self.applyMethod = applyMethod
        self.applyDeadline = applyDeadline
        self.applyDeadlineType = applyDeadlineType
    }
}


public struct RecruitmentPostFetchDTO: Codable {
    public let id: String
    public let isMealAssistance, isBowelAssistance, isWalkingAssistance, isExperiencePreferred: Bool
    public let weekdays: [String]
    public let startTime, endTime, payType: String
    public let payAmount: Int
    public let roadNameAddress, lotNumberAddress, clientName, gender: String
    public let age: Int
    public let weight: Int?
    public let careLevel: Int
    public let mentalStatus: String
    public let disease: String?
    public let lifeAssistance: [String]?
    public let extraRequirement: String?
    public let applyMethod: [String]
    public let applyDeadline: String?
    public let applyDeadlineType: String
    
    public init(
        id: String,
        isMealAssistance: Bool,
        isBowelAssistance: Bool,
        isWalkingAssistance: Bool,
        isExperiencePreferred: Bool,
        weekdays: [String],
        startTime: String,
        endTime: String,
        payType: String,
        payAmount: Int,
        roadNameAddress: String,
        lotNumberAddress: String,
        clientName: String,
        gender: String,
        age: Int,
        weight: Int?,
        careLevel: Int,
        mentalStatus: String,
        disease: String?,
        lifeAssistance: [String]?,
        extraRequirement: String?,
        applyMethod: [String],
        applyDeadline: String?,
        applyDeadlineType: String
    ) {
        self.id = id
        self.isMealAssistance = isMealAssistance
        self.isBowelAssistance = isBowelAssistance
        self.isWalkingAssistance = isWalkingAssistance
        self.isExperiencePreferred = isExperiencePreferred
        self.weekdays = weekdays
        self.startTime = startTime
        self.endTime = endTime
        self.payType = payType
        self.payAmount = payAmount
        self.roadNameAddress = roadNameAddress
        self.lotNumberAddress = lotNumberAddress
        self.clientName = clientName
        self.gender = gender
        self.age = age
        self.weight = weight
        self.careLevel = careLevel
        self.mentalStatus = mentalStatus
        self.disease = disease
        self.lifeAssistance = lifeAssistance
        self.extraRequirement = extraRequirement
        self.applyMethod = applyMethod
        self.applyDeadline = applyDeadline
        self.applyDeadlineType = applyDeadlineType
    }
    
    public func toEntity() -> RegisterRecruitmentPostBundle {
        let workTimeAndPay: WorkTimeAndPayStateObject = .init()
        weekdays.forEach({ dayText in
            let entity = WorkDay.toEntity(text: dayText)
            workTimeAndPay.selectedDays[entity] =  true
        })
        workTimeAndPay.workEndTime = IdleDateComponent.toEntity(text: startTime)
        workTimeAndPay.workEndTime = IdleDateComponent.toEntity(text: endTime)
        workTimeAndPay.paymentType = PaymentType.toEntity(text: payType)
        workTimeAndPay.paymentAmount = String(payAmount)
        
        let addressInfo: AddressInputStateObject = .init()
        addressInfo.addressInfo = .init(
            roadAddress: roadNameAddress,
            jibunAddress: lotNumberAddress
        )
        
        let customerInfo: CustomerInformationStateObject = .init()
        customerInfo.name = clientName
        customerInfo.gender = Gender.toEntity(text: gender)
        
        let currentYear = Calendar.current.component(.year, from: Date())
        customerInfo.birthYear = String(currentYear - age)
        customerInfo.weight = (weight == nil) ? String(weight!) : ""
        customerInfo.careGrade = CareGrade(rawValue: careLevel-1)!
        
        customerInfo.cognitionState = CognitionDegree.toEntity(text: mentalStatus)
        customerInfo.deceaseDescription = disease ?? ""
        
        let customerRequirement: CustomerRequirementStateObject = .init()
        customerRequirement.mealSupportNeeded = isMealAssistance
        customerRequirement.toiletSupportNeeded = isBowelAssistance
        customerRequirement.movingSupportNeeded = isWalkingAssistance
        customerRequirement.additionalRequirement = extraRequirement ?? ""
        lifeAssistance?.forEach({ str in
            let entity = DailySupportType.toEntity(text: str)
            customerRequirement.dailySupportTypeNeeds[entity] = true
        })
        
        let applicationDetail: ApplicationDetailStateObject = .init()
        applicationDetail.experiencePreferenceType = isExperiencePreferred ? .experiencedFirst : .beginnerPossible
        applyMethod.forEach { type in
            let entity = ApplyType.toEntity(text: type)
            applicationDetail.applyType[entity] = true
        }
        applicationDetail.applyDeadlineType = ApplyDeadlineType.toEntity(text: applyDeadlineType)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        applicationDetail.deadlineDate = applyDeadline != nil ? dateFormatter.date(from: applyDeadline!) : nil
        
        return .init(
            workTimeAndPay: workTimeAndPay,
            customerRequirement: customerRequirement,
            customerInformation: customerInfo,
            applicationDetail: applicationDetail,
            addressInfo: addressInfo
        )
    }
}

fileprivate extension ApplyType {
    static func toEntity(text: String) -> ApplyType {
        switch text {
        case "CALLING":
            return .phoneCall
        case "MESSAGE":
            return .message
        case "APP":
            return .app
        default:
            print("ApplyType 디코딩 에러")
            return .phoneCall // 예외 처리용으로 `unknown` 또는 적절한 기본 값을 사용하세요.
        }
    }
}

fileprivate extension ApplyDeadlineType {
    static func toEntity(text: String) -> ApplyDeadlineType {
        switch text {
        case "UNLIMITED":
            return .untilApplicationFinished
        case "LIMITED":
            return .specificDate
        default:
            print("ApplyDeadlineType 디코딩 에러")
            return .untilApplicationFinished // 예외 처리용으로 `unknown` 또는 적절한 기본 값을 사용하세요.
        }
    }
}

fileprivate extension DailySupportType {
    static func toEntity(text: String) -> DailySupportType {
        switch text {
        case "CLEANING":
            return .cleaning
        case "LAUNDRY":
            return .laundry
        case "WALKING":
            return .walking
        case "HEALTH":
            return .exerciseSupport
        case "TALKING":
            return .listener
        default:
            print("DailySupportType 디코딩 에러")
            return .cleaning // 예외 처리용으로 `unknown` 또는 적절한 기본 값을 사용하세요.
        }
    }
}

fileprivate extension Gender {
    static func toEntity(text: String) -> Gender {
        switch text {
        case "MAN":
            return .male
        case "WOMAN":
            return .female
        default:
            print("Gender 디코딩 에러")
            return .notDetermined
        }
    }
}

fileprivate extension PaymentType {
    
    static func toEntity(text: String) -> PaymentType {
        switch text {
        case "HOURLY":
            return .hourly
        case "WEEKLY":
            return .weekly
        case "MONTHLY":
            return .monthly
        default:
            print("PaymentType 디코딩 에러")
            return .hourly
        }
    }
}

fileprivate extension IdleDateComponent {
    
    static func toEntity(text: String) -> IdleDateComponent {
        let timeArr = text.split(separator: ":")
        let hour = timeArr[0]
        let minute = timeArr[1]
        let intHour = Int(hour) ?? 0
        
        let isPM = intHour >= 13
        
        return .init(
            part: isPM ? .PM : .AM,
            hour: String(intHour - (isPM ? 12 : 0)),
            minute: String(minute)
        )
    }
}

fileprivate extension CognitionDegree {
    static func toEntity(text: String) -> CognitionDegree {
        switch text {
        case "NORMAL":
            return .stable
        case "EARLY_STAGE":
            return .earlyStage
        case "OVER_MIDDLE_STAGE":
            return .overEarlyStage
        default:
            print("CognitionDegree 디코딩 에러")
            return .earlyStage
        }
    }
}

fileprivate extension WorkDay {
    
    static func toEntity(text: String) -> WorkDay {
        
        switch text {
            case "MONDAY":
            return WorkDay.mon
            case "TUESDAY":
            return WorkDay.tue
            case "WEDNESDAY":
            return WorkDay.wed
            case "THURSDAY":
            return WorkDay.thu
            case "FRIDAY":
            return WorkDay.fri
            case "SATURDAY":
            return WorkDay.sat
            case "SUNDAY":
            return WorkDay.sun
            default:
                print("WorkDay 디코딩 에러")
                return WorkDay.sun
        }
    }
}
