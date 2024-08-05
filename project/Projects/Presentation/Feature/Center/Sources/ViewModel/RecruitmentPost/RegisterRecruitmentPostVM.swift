//
//  RegisterRecruitmentPostVM.swift
//  CenterFeature
//
//  Created by choijunios on 8/2/24.
//

import Foundation
import RxSwift
import RxCocoa
import Entity
import PresentationCore

public class RegisterRecruitmentPostVM: RegisterRecruitmentPostViewModelable {
    
    public var alert: Driver<DefaultAlertContentVO>?
    
    // MARK: State
    let workTimeAndPay: BehaviorRelay<WorkTimeAndPayStateObject> = .init(value: .init())
    let customerRequirement: BehaviorRelay<CustomerRequirementStateObject> = .init(value: .init())
    let customerInformation: BehaviorRelay<CustomerInformationStateObject> = .init(value: .init())
    let applicationDetail: BehaviorRelay<ApplicationDetailStateObject> = .init(value: .init())
    let addressInfo: BehaviorRelay<AddressInputStateObject> = .init(value: .init())
    
    // MARK: Address input
    public var detailAddress: PublishRelay<String> = .init()
    public var addressInformation: PublishRelay<AddressInformation> = .init()
    
    public var addressInputStateObject: Driver<AddressInputStateObject>
    public var addressInputNextable: Driver<Bool>
    
    // MARK: Work time and pay
    public var selectedDay: PublishRelay<(WorkDay, Bool)> = .init()
    public var workStartTime: PublishRelay<IdleDateComponent> = .init()
    public var workEndTime: PublishRelay<IdleDateComponent> = .init()
    public var paymentType: PublishRelay<PaymentType> = .init()
    public var paymentAmount: PublishRelay<String> = .init()
    
    public var workTimeAndPayStateObject: Driver<WorkTimeAndPayStateObject>
    public var workTimeAndPayNextable: Driver<Bool>
    
    // MARK: Customer requirement
    public var mealSupportNeeded: PublishRelay<Bool> = .init()
    public var toiletSupportNeeded: PublishRelay<Bool> = .init()
    public var movingSupportNeeded: PublishRelay<Bool> = .init()
    public var dailySupportTypes: PublishRelay<(DailySupportType, Bool)> = .init()
    public var additionalRequirement: PublishRelay<String> = .init()
    
    public var customerRequirementStateObject: Driver<CustomerRequirementStateObject>
    public var customerRequirementNextable: Driver<Bool>
    
    // MARK: Customer information
    public var name: PublishRelay<String> = .init()
    public var gender: PublishRelay<Gender> = .init()
    public var birthYear: PublishRelay<String> = .init()
    public var weight: PublishRelay<String> = .init()
    public var careGrade: PublishRelay<CareGrade> = .init()
    public var cognitionState: PublishRelay<CognitionDegree> = .init()
    public var deceaseDescription: PublishRelay<String> = .init()
    
    public var customerInformationStateObject: Driver<CustomerInformationStateObject>
    public var customerInformationNextable: Driver<Bool>
    
    
    // MARK: Application detail
    public var experiencePreferenceType: PublishRelay<ExperiencePreferenceType> = .init()
    public var applyType: PublishRelay<ApplyType> = .init()
    public var applyDeadlineType: PublishRelay<ApplyDeadlineType> = .init()
    public var deadlineDate: BehaviorRelay<Date?> = .init(value: nil)
    
    public var deadlineString: Driver<String>
    public var applicationDetailStateObject: Driver<ApplicationDetailStateObject>
    public var applicationDetailViewNextable: Driver<Bool>
    
    // MARK: PostCard
    public let workerEmployCardVO: Driver<WorkerEmployCardVO>
    
    // 옵셔널한 입력을 유지합니다.
    let disposeBag = DisposeBag()
    
    public init() {
        
        // MARK: Work time and pay
        workTimeAndPayStateObject = workTimeAndPay
            .map { object in
                
                return object
            }
            .asDriver { _ in fatalError() }
        
        let selectedDay_changed = selectedDay
            .map { [workTimeAndPay] (day, isActive) in
                workTimeAndPay.value.selectedDays[day] = isActive
            }

        let workStartTime_changed = workStartTime
            .map { [workTimeAndPay] newValue in
                workTimeAndPay.value.workStartTime = newValue
            }

        let workEndTime_changed = workEndTime
            .map { [workTimeAndPay] newValue in
                workTimeAndPay.value.workEndTime = newValue
            }

        let paymentType_changed = paymentType
            .map { [workTimeAndPay] newValue in
                workTimeAndPay.value.paymentType = newValue
            }

        let paymentAmount_changed = paymentAmount
            .map { [workTimeAndPay] newValue in
                workTimeAndPay.value.paymentAmount = newValue
            }
        
        workTimeAndPayNextable = Observable.combineLatest(
            selectedDay_changed,
            workStartTime_changed,
            workEndTime_changed,
            paymentType_changed,
            paymentAmount_changed
        )
        .map { [workTimeAndPay] _ in
            let object = workTimeAndPay.value
            
            let activeDayCnt = object.selectedDays.keys.reduce(0) { partialResult, key in
                partialResult + (object.selectedDays[key] == true ? 1 : 0)
            }
            
            return activeDayCnt > 0 &&
            object.workStartTime != nil &&
            object.workEndTime != nil &&
            object.paymentType != nil &&
            !object.paymentAmount.isEmpty
        }
        .asDriver(onErrorJustReturn: false)
        
        
        // MARK: Address input
        addressInputStateObject = addressInfo
            .map { object in
                
                return object
            }
            .asDriver { _ in fatalError() }
        
        let addressInformation_changed = addressInformation
            .map { [addressInfo] newValue in
                addressInfo.value.addressInfo = newValue
            }
        
        let detailAddress_changed = detailAddress
            .map { [addressInfo] newValue in
                print(newValue)
                return addressInfo.value.detailAddress = newValue
            }
        
        addressInputNextable = Observable.combineLatest(
            addressInformation_changed,
            detailAddress_changed
        )
        .map { [addressInfo] _ in
            let object = addressInfo.value
            
            return object.addressInfo != nil && !object.detailAddress.isEmpty
        }
        .asDriver(onErrorJustReturn: false)
        
        
        // MARK: Customer requirement
        customerRequirementStateObject = customerRequirement
            .map { object in
                
                return object
            }
            .asDriver { _ in fatalError() }
        
        let mealSupportNeeded_changed = mealSupportNeeded
            .map { [customerRequirement] newValue in
                customerRequirement.value.mealSupportNeeded = newValue
            }
        
        let toiletSupportNeeded_changed = toiletSupportNeeded
            .map { [customerRequirement] newValue in
                customerRequirement.value.toiletSupportNeeded = newValue
            }
        
        let movingSupportNeeded_changed = movingSupportNeeded
            .map { [customerRequirement] newValue in
                customerRequirement.value.movingSupportNeeded = newValue
            }
        
        dailySupportTypes
            .subscribe { [customerRequirement] (type, isAtive) in
                customerRequirement.value.dailySupportTypeNeeds[type] = isAtive
            }
            .disposed(by: disposeBag)
        
        additionalRequirement
            .subscribe { [customerRequirement] newValue in
                customerRequirement.value.additionalRequirement = newValue
            }
            .disposed(by: disposeBag)
        
        customerRequirementNextable = Observable.combineLatest(
            mealSupportNeeded_changed,
            toiletSupportNeeded_changed,
            movingSupportNeeded_changed
        )
        .map { [customerRequirement] _ in
            let requirement = customerRequirement.value
            
            return requirement.mealSupportNeeded != nil &&
                   requirement.toiletSupportNeeded != nil &&
                   requirement.movingSupportNeeded != nil
        }
        .asDriver(onErrorJustReturn: false)
        
        
        
        // MARK: Customer information
        customerInformationStateObject = customerInformation
            .map { object in
                
                return object
            }
            .asDriver { _ in fatalError() }
        
        let name_changed = name
            .map { [customerInformation] newValue in
                customerInformation.value.name = newValue
            }
        
        let gender_changed = gender
            .map { [customerInformation] newValue in
                customerInformation.value.gender = newValue
            }
        
        let birthYear_changed = birthYear
            .map { [customerInformation] newValue in
                customerInformation.value.birthYear = newValue
            }
            
        let weight_changed = weight
            .map { [customerInformation] newValue in
                customerInformation.value.weight = newValue
            }
        
        let careGrade_changed = careGrade
            .map { [customerInformation] newValue in
                customerInformation.value.careGrade = newValue
            }
        
        let cognitionState_changed = cognitionState
            .map { [customerInformation] newValue in
                customerInformation.value.cognitionState = newValue
            }
        
        deceaseDescription
            .subscribe { [customerInformation] newValue in
                customerInformation.value.deceaseDescription = newValue
            }
            .disposed(by: disposeBag)
        
        customerInformationNextable = Observable.combineLatest(
            name_changed,
            gender_changed,
            birthYear_changed,
            weight_changed,
            careGrade_changed,
            cognitionState_changed
        )
        .map { [customerInformation] _ in
            let customerInfo = customerInformation.value
            
            return !customerInfo.name.isEmpty && 
                   !customerInfo.birthYear.isEmpty &&
                   !customerInfo.weight.isEmpty &&
                   customerInfo.careGrade != nil &&
                   customerInfo.cognitionState != nil
        }
        .asDriver(onErrorJustReturn: false)
        
        // MARK: Application detail
        applicationDetailStateObject = applicationDetail
            .map { object in
                
                return object
            }
            .asDriver { _ in fatalError() }
        
        let experiencePreferenceType_changed = experiencePreferenceType
            .map { [applicationDetail] newValue in
                applicationDetail.value.experiencePreferenceType = newValue
            }
        
        let applyType_changed = applyType
            .map { [applicationDetail] newValue in
                applicationDetail.value.applyType = newValue
            }
        
        let applyDeadlineType_changed = applyDeadlineType
            .map { [applicationDetail] newValue in
                applicationDetail.value.applyDeadlineType = newValue
            }
        
        let deadlineDate_changed = deadlineDate
            .map { [applicationDetail] newValue in
                applicationDetail.value.deadlineDate = newValue
            }
        
        deadlineString = deadlineDate
            .compactMap { $0 }
            .map { $0.convertDateToString() }
            .asDriver(onErrorJustReturn: "")
        
        applicationDetailViewNextable = Observable.combineLatest(
            experiencePreferenceType_changed,
            applyType_changed,
            applyDeadlineType_changed,
            deadlineDate_changed
        )
        .map { [applicationDetail] _ in
            
            let state = applicationDetail.value
            
            if state.applyDeadlineType != nil,
               state.applyType != nil,
               state.experiencePreferenceType != nil {
                
                if state.applyDeadlineType == .specificDate {
                    
                    return state.deadlineDate != nil
                }
                return true
            }
            return false
        }
        .asDriver(onErrorJustReturn: false)
        
        // MARK: PostCard
        workerEmployCardVO = Observable<WorkerEmployCardVO>
            .create { [
                workTimeAndPay,
                customerInformation,
                applicationDetail,
                addressInfo
            ] emitter in
                
                // 남은 일수
                var leftDay: Int? = nil
                let calendar = Calendar.current
                let currentDate = Date()
                
                if applicationDetail.value.applyDeadlineType == .specificDate, let deadlineDate = applicationDetail.value.deadlineDate {
                    
                    let component = calendar.dateComponents([.day], from: currentDate, to: deadlineDate)
                    leftDay = component.day
                }
                
                // 초보가능 여부
                let isBeginnerPossible = applicationDetail.value.experiencePreferenceType == .beginnerPossible
                
                // 제목(=도로명주소)
                let title = addressInfo.value.addressInfo?.roadAddress ?? "위치정보 표기 오류"
                
                // 도보시간
                let timeTakenForWalk = "도보 n분"
                
                // 생년
                let birthYear = Int(customerInformation.value.birthYear) ?? 1970
                let currentYear = calendar.component(.year, from: currentDate)
                let targetAge = currentYear - birthYear + 1
                
                // 요양등급
                let targetLavel: Int = (customerInformation.value.careGrade?.rawValue ?? 0)+1
                
                // 성별
                let targetGender = customerInformation.value.gender
                
                // 근무 요일
                let days = workTimeAndPay.value.selectedDays.filter { (_, value) in
                    value
                }.map { (key, _) in
                    key
                }
                
                // 근무 시작, 종료시간
                let startTime = workTimeAndPay.value.workStartTime?.convertToStringForButton() ?? "00:00"
                let workEndTime = workTimeAndPay.value.workEndTime?.convertToStringForButton() ?? "00:00"
                
                // 급여타입및 양
                let paymentType = workTimeAndPay.value.paymentType ?? .hourly
                let paymentAmount = workTimeAndPay.value.paymentAmount
                
                let vo = WorkerEmployCardVO(
                    dayLeft: leftDay ?? 0,
                    isBeginnerPossible: isBeginnerPossible,
                    title: title,
                    timeTakenForWalk: timeTakenForWalk,
                    targetAge: targetAge,
                    targetLevel: targetLavel,
                    targetGender: targetGender ?? .notDetermined,
                    days: days,
                    startTime: startTime,
                    endTime: workEndTime,
                    paymentType: paymentType,
                    paymentAmount: paymentAmount
                )
                
                emitter.onNext(vo)
                
                return Disposables.create { }
            }
            .asDriver(onErrorJustReturn: .mock)
    }
}

extension Date {
    func convertDateToString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        return dateFormatter.string(from: self)
    }
}
