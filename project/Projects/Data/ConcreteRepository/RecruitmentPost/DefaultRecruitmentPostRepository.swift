//
//  Default.swift
//  ConcreteRepository
//
//  Created by choijunios on 8/8/24.
//

import RepositoryInterface
import RxSwift
import Entity
import NetworkDataSource
import Foundation

public class DefaultRecruitmentPostRepository: RecruitmentPostRepository {
    
    private var service: RecruitmentPostService = .init()
    
    public init(_ store: KeyValueStore? = nil) {
        if let store {
            self.service = RecruitmentPostService(keyValueStore: store)
        }
    }
    
    public func registerPost(input1: Entity.WorkTimeAndPayStateObject, input2: Entity.AddressInputStateObject, input3: Entity.CustomerInformationStateObject, input4: Entity.CustomerRequirementStateObject, input5: Entity.ApplicationDetailStateObject) -> RxSwift.Single<Void> {
        
        // WorkTimeAndPayment
        // - all required
        let weekDays: [String] = input1.selectedDays
            .filter ({ (key, value) in value }).keys
            .map { day in day.dtoFormString }
        
        let startTime: String = input1.workStartTime!.dtoFormString
        let endTime: String = input1.workEndTime!.dtoFormString
        let paymentType: String = input1.paymentType!.dtoFormString
        let paymentAmount: Int = .init(input1.paymentAmount)!
        
        // AddressInputStateObject
        // - all required
        let roadNameAddress: String = input2.addressInfo!.roadAddress
        let lotNumberAddress: String = input2.addressInfo!.jibunAddress
        
        // CustomerInformationStateObject
        // - required
        let clientName: String = input3.name
        let gender: String = input3.gender!.dtoFormString
        let birthYear: Int = .init(input3.birthYear)!
        let weight: Int = .init(input3.weight)!
        let careLevel: Int = input3.careGrade!.dtoFormInt
        let mentalStatus: String = input3.cognitionState!.dtoFormString
        // - optional
        let disease: String = input3.deceaseDescription
        
        // CustomerRequirementStateObject
        // - required
        let isMealAssistance: Bool = input4.mealSupportNeeded!
        let isBowelAssistance: Bool = input4.toiletSupportNeeded!
        let isWalkingAssistance: Bool = input4.movingSupportNeeded!
        // - optional
        let extraRequirement: String = input4.additionalRequirement
        let lifeAssistance: [String] = input4.dailySupportTypeNeeds
            .filter ({ $1 }).keys
            .map { type in type.dtoFormString }
        
        // ApplicationDetailStateObject
        // - required
        let isExperiencePreferred = input5.experiencePreferenceType! == .beginnerPossible ? false : true
        let applyMethod = input5.applyType
            .filter ({ $1 }).keys
            .map { type in type.dtoFormString }
        let applyDeadlineType = input5.applyDeadlineType!.dtoFormString
        let applyDeadline = input5.deadlineDate!.dtoFormString
        
        let dto = RecruitmentPostRegisterDTO(
            isMealAssistance: isMealAssistance,
            isBowelAssistance: isBowelAssistance,
            isWalkingAssistance: isWalkingAssistance,
            isExperiencePreferred: isExperiencePreferred,
            weekdays: weekDays,
            startTime: startTime,
            endTime: endTime,
            payType: paymentType,
            payAmount: paymentAmount,
            roadNameAddress: roadNameAddress,
            lotNumberAddress: lotNumberAddress,
            clientName: clientName,
            gender: gender,
            birthYear: birthYear,
            weight: weight,
            careLevel: careLevel,
            mentalStatus: mentalStatus,
            disease: disease,
            lifeAssistance: lifeAssistance,
            extraRequirement: extraRequirement,
            applyMethod: applyMethod,
            applyDeadline: applyDeadline,
            applyDeadlineType: applyDeadlineType
        )
        
        let encodedData = try! JSONEncoder().encode(dto)
        
        return service.request(api: .registerPost(postData: encodedData), with: .withToken)
            .map { _ in () }
    }
    
    public func getPostDetailForCenter(id: String) -> RxSwift.Single<Entity.RegisterRecruitmentPostBundle> {
        
        service.request(api: .postDetail(id: id, userType: .center), with: .withToken)
            .map(RecruitmentPostFetchDTO.self)
            .map { dto in
                dto.toEntity()
            }
    }
}

    
// MARK: 엔티티 타입들을 DTO로 변경하기 위한 확장
fileprivate extension WorkDay {
    
    var dtoFormString: String {
        switch self {
        case .mon:
            "MONDAY"
        case .tue:
            "TUESDAY"
        case .wed:
            "WEDNESDAY"
        case .thu:
            "THURSDAY"
        case .fri:
            "FRIDAY"
        case .sat:
            "SATURDAY"
        case .sun:
            "SUNDAY"
        }
    }
}

fileprivate extension IdleDateComponent {
    var dtoFormString: String {
        if part == .AM {
            return "\(hour):\(minute)"
        } else {
            return "\(Int(hour)! + 12):\(minute)"
        }
    }
}

fileprivate extension PaymentType {
    var dtoFormString: String {
        switch self {
        case .hourly:
            "HOURLY"
        case .weekly:
            "WEEKLY"
        case .monthly:
            "MONTHLY"
        }
    }
}

fileprivate extension Gender {
    var dtoFormString: String {
        switch self {
        case .male:
            "MAN"
        case .female:
            "WOMAN"
        case .notDetermined:
            fatalError()
        }
    }
}

fileprivate extension CareGrade {
    var dtoFormInt: Int {
        self.rawValue + 1
    }
}

fileprivate extension CognitionDegree {
    var dtoFormString: String {
        switch self {
        case .stable:
            "NORMAL"
        case .earlyStage:
            "EARLY_STAGE"
        case .overEarlyStage:
            "OVER_MIDDLE_STAGE"
        }
    }
}

fileprivate extension DailySupportType {
    var dtoFormString: String {
        switch self {
        case .cleaning:
            "CLEANING"
        case .laundry:
            "LAUNDRY"
        case .walking:
            "WALKING"
        case .exerciseSupport:
            "HEALTH"
        case .listener:
            "TALKING"
        }
    }
}

fileprivate extension ApplyType {
    var dtoFormString: String {
        switch self {
        case .phoneCall:
            "CALLING"
        case .message:
            "MESSAGE"
        case .app:
            "APP"
        }
    }
}

fileprivate extension ApplyDeadlineType {
    var dtoFormString: String {
        switch self {
        case .untilApplicationFinished:
            "UNLIMITED"
        case .specificDate:
            "LIMITED"
        }
    }
}

fileprivate extension Date {
    var dtoFormString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
}
