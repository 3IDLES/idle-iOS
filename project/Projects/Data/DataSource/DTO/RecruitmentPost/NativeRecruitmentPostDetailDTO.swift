//
//  NativeRecruitmentPostDetailDTO.swift
//  NetworkDataSource
//
//  Created by choijunios on 8/15/24.
//

import Foundation
import Entity

public struct NativeRecruitmentPostDetailDTO: EntityRepresentable {
    public let id: String
    
    public let longitude: String
    public let latitude: String
    
    public let centerId: String
    public let centerName: String
    public let centerRoadNameAddress: String

    public let distance: Int
    
    public let isMealAssistance: Bool
    public let isBowelAssistance: Bool
    public let isWalkingAssistance: Bool
    public let isExperiencePreferred: Bool
    
    public let weekdays: [String]
    public let startTime: String
    public let endTime: String
    public let payType: String
    public let payAmount: Int
    public let roadNameAddress: String
    public let lotNumberAddress: String
    public let gender: String
    public let age: Int
    public let weight: Int?
    public let careLevel: Int
    public let mentalStatus: String
    public let disease: String?
    public let lifeAssistance: [String]?
    public let extraRequirement: String?
    public let applyMethod: [String]
    public let applyDeadlineType: String
    public let applyDeadline: String?
    
    public let applyTime: String?
    public let isFavorite: Bool
    
    public func toEntity() -> RecruitmentPostForWorkerBundle {
        
        let workTimeAndPay: WorkTimeAndPayStateObject = .init()
        weekdays.forEach({ dayText in
            let entity = WorkDay.toEntity(text: dayText)
            workTimeAndPay.selectedDays[entity] =  true
        })
        workTimeAndPay.workStartTime = IdleDateComponent.toEntity(text: startTime)
        workTimeAndPay.workEndTime = IdleDateComponent.toEntity(text: endTime)
        workTimeAndPay.paymentType = PaymentType.toEntity(text: payType)
        workTimeAndPay.paymentAmount = String(payAmount)
        
        let addressInfo: AddressInputStateObject = .init()
        addressInfo.addressInfo = .init(
            roadAddress: roadNameAddress,
            jibunAddress: lotNumberAddress
        )
        
        let customerInfo: CustomerInformationStateObject = .init()
        customerInfo.gender = Gender.toEntity(text: gender)
        
        let currentYear = Calendar.current.component(.year, from: Date())
        customerInfo.birthYear = String(currentYear - age)
        customerInfo.weight = (weight == nil) ? "" : String(weight!)
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
        
        // MARK: CenterInfo
        let centerInfo: RecruitmentPostForWorkerBundle.CenterInfo = .init(
            centerId: centerId,
            centerName: centerName,
            centerRoadAddress: centerRoadNameAddress
        )
        
        let jobLocation: LocationInformation = .init(
            longitude: Double(longitude)!,
            latitude: Double(latitude)!
        )
        
        // MARK: Apply date
        let applyDate = applyTime != nil ? dateFormatter.date(from: applyTime!) : nil
        
        return .init(
            isFavorite: isFavorite,
            applyDate: applyDate,
            workTimeAndPay: workTimeAndPay,
            customerRequirement: customerRequirement,
            customerInformation: customerInfo,
            applicationDetail: applicationDetail,
            addressInfo: addressInfo,
            centerInfo: centerInfo,
            jobLocation: jobLocation,
            distanceToWorkPlace: distance
        )
    }
}

