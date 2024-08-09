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
    var state_workTimeAndPay: WorkTimeAndPayStateObject = .init()
    var state_customerRequirement: CustomerRequirementStateObject = .init()
    var state_customerInformation: CustomerInformationStateObject = .init()
    var state_applicationDetail: ApplicationDetailStateObject = .init()
    var state_addressInfo: AddressInputStateObject = .init()
    
    // MARK: Editing
    let editing_workTimeAndPay: BehaviorRelay<WorkTimeAndPayStateObject> = .init(value: .init())
    let editing_customerRequirement: BehaviorRelay<CustomerRequirementStateObject> = .init(value: .init())
    let editing_customerInformation: BehaviorRelay<CustomerInformationStateObject> = .init(value: .init())
    let editing_applicationDetail: BehaviorRelay<ApplicationDetailStateObject> = .init(value: .init())
    let editing_addressInfo: BehaviorRelay<AddressInputStateObject> = .init(value: .init())
    
    // MARK: Casting
    public var casting_addressInput: Driver<AddressInputStateObject>
    public var casting_workTimeAndPay: Driver<WorkTimeAndPayStateObject>
    public var casting_customerRequirement: Driver<CustomerRequirementStateObject>
    public var casting_customerInformation: Driver<CustomerInformationStateObject>
    public var casting_applicationDetail: Driver<ApplicationDetailStateObject>
    
    // MARK: Address input
    public var detailAddress: PublishRelay<String> = .init()
    public var addressInformation: PublishRelay<AddressInformation> = .init()
    
    public var addressInputNextable: Driver<Bool>
    
    // MARK: Work time and pay
    public var selectedDay: PublishRelay<(WorkDay, Bool)> = .init()
    public var workStartTime: PublishRelay<IdleDateComponent> = .init()
    public var workEndTime: PublishRelay<IdleDateComponent> = .init()
    public var paymentType: PublishRelay<PaymentType> = .init()
    public var paymentAmount: PublishRelay<String> = .init()
    
    
    public var workTimeAndPayNextable: Driver<Bool>
    
    // MARK: Customer requirement
    public var mealSupportNeeded: PublishRelay<Bool> = .init()
    public var toiletSupportNeeded: PublishRelay<Bool> = .init()
    public var movingSupportNeeded: PublishRelay<Bool> = .init()
    public var dailySupportTypes: PublishRelay<(DailySupportType, Bool)> = .init()
    public var additionalRequirement: PublishRelay<String> = .init()
    
    public var customerRequirementNextable: Driver<Bool>
    
    // MARK: Customer information
    public var name: PublishRelay<String> = .init()
    public var gender: PublishRelay<Gender> = .init()
    public var birthYear: PublishRelay<String> = .init()
    public var weight: PublishRelay<String> = .init()
    public var careGrade: PublishRelay<CareGrade> = .init()
    public var cognitionState: PublishRelay<CognitionDegree> = .init()
    public var deceaseDescription: PublishRelay<String> = .init()
    
    public var customerInformationNextable: Driver<Bool>
    
    
    // MARK: Application detail
    public var experiencePreferenceType: PublishRelay<ExperiencePreferenceType> = .init()
    public var applyType: PublishRelay<(Entity.ApplyType, Bool)> = .init()
    public var applyDeadlineType: PublishRelay<ApplyDeadlineType> = .init()
    public var deadlineDate: BehaviorRelay<Date?> = .init(value: nil)
    
    public var deadlineString: Driver<String>
    public var applicationDetailViewNextable: Driver<Bool>
    
    // MARK: PostCard
    public let workerEmployCardVO: Driver<WorkerEmployCardVO>
    
    // 옵셔널한 입력을 유지합니다.
    let disposeBag = DisposeBag()
    
    public init() {
        
        // MARK: Work time and pay
        casting_workTimeAndPay = editing_workTimeAndPay.asDriver { _ in fatalError() }
        
        let selectedDay_changed = selectedDay
            .map { [editing_workTimeAndPay] (day, isActive) in
                editing_workTimeAndPay.value.selectedDays[day] = isActive
            }

        let workStartTime_changed = workStartTime
            .map { [editing_workTimeAndPay] newValue in
                editing_workTimeAndPay.value.workStartTime = newValue
            }

        let workEndTime_changed = workEndTime
            .map { [editing_workTimeAndPay] newValue in
                editing_workTimeAndPay.value.workEndTime = newValue
            }

        let paymentType_changed = paymentType
            .map { [editing_workTimeAndPay] newValue in
                editing_workTimeAndPay.value.paymentType = newValue
            }

        let paymentAmount_changed = paymentAmount
            .map { [editing_workTimeAndPay] newValue in
                editing_workTimeAndPay.value.paymentAmount = newValue
            }
        
        workTimeAndPayNextable = Observable.combineLatest(
            selectedDay_changed,
            workStartTime_changed,
            workEndTime_changed,
            paymentType_changed,
            paymentAmount_changed
        )
        .map { [editing_workTimeAndPay] _ in
            let object = editing_workTimeAndPay.value
            
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
        casting_addressInput = editing_addressInfo.asDriver { _ in fatalError() }
        
        let addressInformation_changed = addressInformation
            .map { [editing_addressInfo] newValue in
                editing_addressInfo.value.addressInfo = newValue
            }
        
        let detailAddress_changed = detailAddress
            .map { [editing_addressInfo] newValue in
                editing_addressInfo.value.detailAddress = newValue
            }
        
        addressInputNextable = Observable.combineLatest(
            addressInformation_changed,
            detailAddress_changed
        )
        .map { [editing_addressInfo] _ in
            let object = editing_addressInfo.value
            
            return object.addressInfo != nil && !object.detailAddress.isEmpty
        }
        .asDriver(onErrorJustReturn: false)
        
        
        // MARK: Customer requirement
        casting_customerRequirement = editing_customerRequirement.asDriver { _ in fatalError() }
        
        let mealSupportNeeded_changed = mealSupportNeeded
            .map { [editing_customerRequirement] newValue in
                editing_customerRequirement.value.mealSupportNeeded = newValue
            }
        
        let toiletSupportNeeded_changed = toiletSupportNeeded
            .map { [editing_customerRequirement] newValue in
                editing_customerRequirement.value.toiletSupportNeeded = newValue
            }
        
        let movingSupportNeeded_changed = movingSupportNeeded
            .map { [editing_customerRequirement] newValue in
                editing_customerRequirement.value.movingSupportNeeded = newValue
            }
        
        dailySupportTypes
            .subscribe { [editing_customerRequirement] (type, isAtive) in
                editing_customerRequirement.value.dailySupportTypeNeeds[type] = isAtive
            }
            .disposed(by: disposeBag)
        
        additionalRequirement
            .subscribe { [editing_customerRequirement] newValue in
                editing_customerRequirement.value.additionalRequirement = newValue
            }
            .disposed(by: disposeBag)
        
        customerRequirementNextable = Observable.combineLatest(
            mealSupportNeeded_changed,
            toiletSupportNeeded_changed,
            movingSupportNeeded_changed
        )
        .map { [editing_customerRequirement] _ in
            let requirement = editing_customerRequirement.value
            
            return requirement.mealSupportNeeded != nil &&
                   requirement.toiletSupportNeeded != nil &&
                   requirement.movingSupportNeeded != nil
        }
        .asDriver(onErrorJustReturn: false)
        
        
        
        // MARK: Customer information
        casting_customerInformation = editing_customerInformation.asDriver { _ in fatalError() }
        
        let name_changed = name
            .map { [editing_customerInformation] newValue in
                editing_customerInformation.value.name = newValue
            }
        
        let gender_changed = gender
            .map { [editing_customerInformation] newValue in
                editing_customerInformation.value.gender = newValue
            }
        
        let birthYear_changed = birthYear
            .map { [editing_customerInformation] newValue in
                editing_customerInformation.value.birthYear = newValue
            }
            
        let weight_changed = weight
            .map { [editing_customerInformation] newValue in
                editing_customerInformation.value.weight = newValue
            }
        
        let careGrade_changed = careGrade
            .map { [editing_customerInformation] newValue in
                editing_customerInformation.value.careGrade = newValue
            }
        
        let cognitionState_changed = cognitionState
            .map { [editing_customerInformation] newValue in
                editing_customerInformation.value.cognitionState = newValue
            }
        
        deceaseDescription
            .subscribe { [editing_customerInformation] newValue in
                editing_customerInformation.value.deceaseDescription = newValue
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
        .map { [editing_customerInformation] _ in
            let customerInfo = editing_customerInformation.value
            
            return !customerInfo.name.isEmpty && 
                   !customerInfo.birthYear.isEmpty &&
                   !customerInfo.weight.isEmpty &&
                   customerInfo.careGrade != nil &&
                   customerInfo.cognitionState != nil
        }
        .asDriver(onErrorJustReturn: false)
        
        // MARK: Application detail
        casting_applicationDetail = editing_applicationDetail.asDriver { _ in fatalError() }
        
        let experiencePreferenceType_changed = experiencePreferenceType
            .map { [editing_applicationDetail] newValue in
                editing_applicationDetail.value.experiencePreferenceType = newValue
            }
        
        let applyType_changed = applyType
            .map { [editing_applicationDetail] (applyType, isActive) in
                editing_applicationDetail.value.applyType[applyType] = isActive
            }
        
        let applyDeadlineType_changed = applyDeadlineType
            .map { [editing_applicationDetail] newValue in
                editing_applicationDetail.value.applyDeadlineType = newValue
            }
        
        let deadlineDate_changed = deadlineDate
            .map { [editing_applicationDetail] newValue in
                editing_applicationDetail.value.deadlineDate = newValue
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
        .map { [editing_applicationDetail] _ in
            
            let state = editing_applicationDetail.value
            
            let activeApplyTypeCnt = state.applyType.reduce(0) { partialResult, keyValue in
                partialResult + (keyValue.value ? 1 : 0)
            }
            
            if state.applyDeadlineType != nil,
               activeApplyTypeCnt != 0,
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
                editing_workTimeAndPay,
                editing_customerInformation,
                editing_applicationDetail,
                editing_addressInfo
            ] emitter in
                
                // 남은 일수
                var leftDay: Int? = nil
                let calendar = Calendar.current
                let currentDate = Date()
                
                if editing_applicationDetail.value.applyDeadlineType == .specificDate, let deadlineDate = editing_applicationDetail.value.deadlineDate {
                    
                    let component = calendar.dateComponents([.day], from: currentDate, to: deadlineDate)
                    leftDay = component.day
                }
                
                // 초보가능 여부
                let isBeginnerPossible = editing_applicationDetail.value.experiencePreferenceType == .beginnerPossible
                
                // 제목(=도로명주소)
                let title = editing_addressInfo.value.addressInfo?.roadAddress ?? "위치정보 표기 오류"
                
                // 도보시간
                let timeTakenForWalk = "도보 n분"
                
                // 생년
                let birthYear = Int(editing_customerInformation.value.birthYear) ?? 1970
                let currentYear = calendar.component(.year, from: currentDate)
                let targetAge = currentYear - birthYear + 1
                
                // 요양등급
                let targetLavel: Int = (editing_customerInformation.value.careGrade?.rawValue ?? 0)+1
                
                // 성별
                let targetGender = editing_customerInformation.value.gender
                
                // 근무 요일
                let days = editing_workTimeAndPay.value.selectedDays.filter { (_, value) in
                    value
                }.map { (key, _) in
                    key
                }
                
                // 근무 시작, 종료시간
                let startTime = editing_workTimeAndPay.value.workStartTime?.convertToStringForButton() ?? "00:00"
                let workEndTime = editing_workTimeAndPay.value.workEndTime?.convertToStringForButton() ?? "00:00"
                
                // 급여타입및 양
                let paymentType = editing_workTimeAndPay.value.paymentType ?? .hourly
                let paymentAmount = editing_workTimeAndPay.value.paymentAmount
                
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
        
        
            // 최초로 데이터를 가져옵니다.
            fetchFromState()
    }
    
    
    public func fetchFromState() {
        
        editing_workTimeAndPay.accept(state_workTimeAndPay.copy() as! WorkTimeAndPayStateObject)
        editing_customerRequirement.accept(state_customerRequirement.copy() as! CustomerRequirementStateObject)
        editing_customerInformation.accept(state_customerInformation.copy() as! CustomerInformationStateObject)
        editing_applicationDetail.accept(state_applicationDetail.copy() as! ApplicationDetailStateObject)
        editing_addressInfo.accept(state_addressInfo.copy() as! AddressInputStateObject)
    }
    
    public func updateToState() {
        
        state_workTimeAndPay = editing_workTimeAndPay.value.copy() as! WorkTimeAndPayStateObject
        state_customerRequirement = editing_customerRequirement.value.copy() as! CustomerRequirementStateObject
        state_customerInformation = editing_customerInformation.value.copy() as! CustomerInformationStateObject
        state_applicationDetail = editing_applicationDetail.value.copy() as! ApplicationDetailStateObject
        state_addressInfo = editing_addressInfo.value.copy() as! AddressInputStateObject
    }
}
