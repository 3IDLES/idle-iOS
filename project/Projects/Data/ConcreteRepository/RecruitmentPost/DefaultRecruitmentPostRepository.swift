//
//  Default.swift
//  ConcreteRepository
//
//  Created by choijunios on 8/8/24.
//

import RepositoryInterface
import RxSwift
import Entity
import DataSource
import Foundation
import Moya

public class DefaultRecruitmentPostRepository: RecruitmentPostRepository {
    
    private var service: RecruitmentPostService = .init()
    
    public init(_ store: KeyValueStore? = nil) {
        if let store {
            self.service = RecruitmentPostService(keyValueStore: store)
        }
    }
    
    // MARK:  Center
    public func registerPost(bundle: RegisterRecruitmentPostBundle) -> RxSwift.Single<Void> {
        
        let encodedData = try! JSONEncoder().encode(bundle.toDTO())
        
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
    
    public func editPostDetail(id: String, bundle: RegisterRecruitmentPostBundle) -> RxSwift.Single<Void> {
        
        let encodedData = try! JSONEncoder().encode(bundle.toDTO())
        
        return service.request(
            api: .editPost(id: id, postData: encodedData),
            with: .withToken
        ).map { _ in () }
    }
    
    public func getOngoingPosts() -> RxSwift.Single<[Entity.RecruitmentPostInfoForCenterVO]> {
        return service.request(api: .getOnGoingPosts, with: .withToken)
            .map(RecruitmentPostForCenterListDTO.self)
            .map({ $0.jobPostings.map { $0.toVO() } })
    }
    
    public func getClosedPosts() -> RxSwift.Single<[Entity.RecruitmentPostInfoForCenterVO]> {
        return service.request(api: .getClosedPosts, with: .withToken)
            .map(RecruitmentPostForCenterListDTO.self)
            .map({ $0.jobPostings.map { $0.toVO() } })
    }
    
    public func getPostApplicantCount(id: String) -> RxSwift.Single<Int> {
        service.request(api: .getPostApplicantCount(id: id), with: .withToken)
            .map(PostApplicantCountDTO.self)
            .map { dto in
                dto.applicantCount
            }
    }
    
    // MARK: Worker
    public func getPostDetailForWorker(id: String) -> RxSwift.Single<Entity.RecruitmentPostForWorkerBundle> {
        service.request(
            api: .postDetail(id: id, userType: .worker),
            with: .withToken
        )
        .map(RecruitmentPostDTO.self)
        .map { dto in
            dto.toEntity()
        }
    }
    
    public func getNativePostListForWorker(nextPageId: String?, requestCnt: Int = 10) -> RxSwift.Single<Entity.RecruitmentPostListForWorkerVO> {
        
        service.request(
            api: .getOnGoingNativePostListForWorker(nextPageId: nextPageId, requestCnt: String(requestCnt)),
            with: .withToken
        )
        .map(RecruitmentPostListForWorkerDTO.self)
        .catch({ error in
            if let moyaError = error as? MoyaError, case .objectMapping(let error, _) = moyaError {
                print(error.localizedDescription)
            }
            return .error(error)
        })
        .map { dto in
            dto.toEntity()
        }
    }
}

// MARK: 공고등록 정보를 DTO로 변환하는 영역
extension RegisterRecruitmentPostBundle {
    
    func toDTO() -> RecruitmentPostRegisterDTO {
        
        // WorkTimeAndPayment
        // - all required
        let weekDays: [String] = workTimeAndPay.selectedDays
            .filter ({ (key, value) in value }).keys
            .map { day in day.dtoFormString }
        
        let startTime: String = workTimeAndPay.workStartTime!.dtoFormString
        let endTime: String = workTimeAndPay.workEndTime!.dtoFormString
        let paymentType: String = workTimeAndPay.paymentType!.dtoFormString
        let paymentAmount: Int = .init(workTimeAndPay.paymentAmount)!
        
        // AddressInputStateObject
        // - all required
        let roadNameAddress: String = addressInfo.addressInfo!.roadAddress
        let lotNumberAddress: String = addressInfo.addressInfo!.jibunAddress
        
        // CustomerInformationStateObject
        // - required
        let clientName: String = customerInformation.name
        let gender: String = customerInformation.gender!.dtoFormString
        let birthYear: Int = .init(customerInformation.birthYear)!
        let weight: Int? = .init(customerInformation.weight) ?? nil
        let careLevel: Int = customerInformation.careGrade!.dtoFormInt
        let mentalStatus: String = customerInformation.cognitionState!.dtoFormString
        // - optional
        let disease: String? = customerInformation.deceaseDescription.isEmpty ? nil : customerInformation.deceaseDescription
        
        // CustomerRequirementStateObject
        // - required
        let isMealAssistance: Bool = customerRequirement.mealSupportNeeded!
        let isBowelAssistance: Bool = customerRequirement.toiletSupportNeeded!
        let isWalkingAssistance: Bool = customerRequirement.movingSupportNeeded!
        // - optional
        let extraRequirement: String? = customerRequirement.additionalRequirement.isEmpty ? nil  :customerRequirement.additionalRequirement
        let lifAssistanceList = customerRequirement.dailySupportTypeNeeds
            .filter ({ $1 }).keys
            .map { type in type.dtoFormString }
        let lifeAssistance: [String] = lifAssistanceList.isEmpty ? ["NONE"] : lifAssistanceList
        
        // ApplicationDetailStateObject
        // - required
        let isExperiencePreferred = applicationDetail.experiencePreferenceType! == .beginnerPossible ? false : true
        let applyMethod = applicationDetail.applyType
            .filter ({ $1 }).keys
            .map { type in type.dtoFormString }
        let applyDeadlineType = applicationDetail.applyDeadlineType!.dtoFormString
        let applyDeadline = applicationDetail.deadlineDate!.dtoFormString
        
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
        return dto
    }
}
    
// MARK: 엔티티 타입들을 DTO로 변경하기 위한 확장
extension WorkDay {
    
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

extension IdleDateComponent {
    var dtoFormString: String {
        if part == .AM {
            return "\(hour):\(minute)"
        } else {
            return "\(Int(hour)! + 12):\(minute)"
        }
    }
}

extension PaymentType {
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

extension Gender {
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

extension CareGrade {
    var dtoFormInt: Int {
        self.rawValue + 1
    }
}

extension CognitionDegree {
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

extension DailySupportType {
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

extension ApplyType {
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

extension ApplyDeadlineType {
    var dtoFormString: String {
        switch self {
        case .untilApplicationFinished:
            "UNLIMITED"
        case .specificDate:
            "LIMITED"
        }
    }
}

extension Date {
    var dtoFormString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
}
