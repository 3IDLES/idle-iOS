//
//  EditPostVM.swift
//  CenterFeature
//
//  Created by choijunios on 8/14/24.
//

import Foundation
import Domain
import PresentationCore
import BaseFeature


import RxSwift
import RxCocoa

public class EditPostVM: BaseViewModel, EditPostViewModelable {
    
    // Init
    let id: String
    let recruitmentPostUseCase: RecruitmentPostUseCase
    
    // MARK: Edit Screen
    public var editPostViewWillAppear: RxRelay.PublishRelay<Void> = .init()
    public weak var editPostCoordinator: EditPostCoordinator?
    public var editViewExitButtonClicked: RxRelay.PublishRelay<Void> = .init()
    public var saveButtonClicked: RxRelay.PublishRelay<Void> = .init()
    public var requestSaveFailure: RxCocoa.Driver<DefaultAlertContentVO>?
    
    // MARK: State
    var state_workTimeAndPay: WorkTimeAndPayStateObject = .init()
    var state_customerRequirement: CustomerRequirementStateObject = .init()
    var state_customerInformation: CustomerInformationStateObject = .init()
    var state_applicationDetail: ApplicationDetailStateObject = .init()
    var state_addressInfo: AddressInputStateObject = .init()
    
    // MARK: Editing
    private let editing_workTimeAndPay: BehaviorRelay<WorkTimeAndPayStateObject> = .init(value: .init())
    private let editing_customerRequirement: BehaviorRelay<CustomerRequirementStateObject> = .init(value: .init())
    private let editing_customerInformation: BehaviorRelay<CustomerInformationStateObject> = .init(value: .init())
    private let editing_applicationDetail: BehaviorRelay<ApplicationDetailStateObject> = .init(value: .init())
    private let editing_addressInfo: BehaviorRelay<AddressInputStateObject> = .init(value: .init())
    
    // MARK: Casting
    public var casting_addressInput: Driver<AddressInputStateObject>?
    public var casting_workTimeAndPay: Driver<WorkTimeAndPayStateObject>?
    public var casting_customerRequirement: Driver<CustomerRequirementStateObject>?
    public var casting_customerInformation: Driver<CustomerInformationStateObject>?
    public var casting_applicationDetail: Driver<ApplicationDetailStateObject>?
    
    // MARK: Address input
    public var addressInformation: PublishRelay<AddressInformation> = .init()
    
    // MARK: Work time and pay
    public var selectedDay: PublishRelay<(WorkDay, Bool)> = .init()
    public var workStartTime: PublishRelay<IdleDateComponent> = .init()
    public var workEndTime: PublishRelay<IdleDateComponent> = .init()
    public var paymentType: PublishRelay<PaymentType> = .init()
    public var paymentAmount: PublishRelay<String> = .init()

    
    // MARK: Customer requirement
    public var mealSupportNeeded: PublishRelay<Bool> = .init()
    public var toiletSupportNeeded: PublishRelay<Bool> = .init()
    public var movingSupportNeeded: PublishRelay<Bool> = .init()
    public var dailySupportTypes: PublishRelay<(DailySupportType, Bool)> = .init()
    public var additionalRequirement: PublishRelay<String> = .init()
    
    
    
    // MARK: Customer information
    public var name: PublishRelay<String> = .init()
    public var gender: PublishRelay<Gender> = .init()
    public var birthYear: PublishRelay<String> = .init()
    public var weight: PublishRelay<String> = .init()
    public var careGrade: PublishRelay<CareGrade> = .init()
    public var cognitionState: PublishRelay<CognitionDegree> = .init()
    public var deceaseDescription: PublishRelay<String> = .init()
    
    
    
    
    // MARK: Application detail
    public var experiencePreferenceType: PublishRelay<ExperiencePreferenceType> = .init()
    public var applyType: PublishRelay<(ApplyType, Bool)> = .init()
    public var applyDeadlineType: PublishRelay<ApplyDeadlineType> = .init()
    public var deadlineDate: BehaviorRelay<Date?> = .init(value: nil)
    
    public var deadlineString: Driver<String>?


    public var addressInputNextable: Driver<Bool>?
    public var workTimeAndPayNextable: Driver<Bool>?
    public var customerRequirementNextable: Driver<Bool>?
    public var customerInformationNextable: Driver<Bool>?
    public var applicationDetailViewNextable: Driver<Bool>?
    
    
    // MARK: 모든 섹션의 유효성 확인
    private let validationStateQueue = DispatchQueue.global(qos: .userInteractive)
    private var validationState: [RegisterRecruitmentPostInputSection: Bool] = {
        var dict: [RegisterRecruitmentPostInputSection: Bool] = [:]
        RegisterRecruitmentPostInputSection.allCases.forEach { section in
            dict[section] = false
        }
        return dict
    }()
    
    public init(
        id: String,
        recruitmentPostUseCase: RecruitmentPostUseCase
    ) {
        self.id = id
        self.recruitmentPostUseCase = recruitmentPostUseCase
        
        super.init()
        
        // MARK: Work time and pay
        casting_workTimeAndPay = editing_workTimeAndPay.asDriver(onErrorJustReturn: .mock)
        
        selectedDay
            .subscribe { [editing_workTimeAndPay] (day, isActive) in
                editing_workTimeAndPay.value.selectedDays[day] = isActive
            }
            .disposed(by: disposeBag)

        workStartTime
            .subscribe { [editing_workTimeAndPay] newValue in
                editing_workTimeAndPay.value.workStartTime = newValue
            }
            .disposed(by: disposeBag)

        workEndTime
            .subscribe { [editing_workTimeAndPay] newValue in
                editing_workTimeAndPay.value.workEndTime = newValue
            }
            .disposed(by: disposeBag)

        paymentType
            .subscribe { [editing_workTimeAndPay] newValue in
                editing_workTimeAndPay.value.paymentType = newValue
            }
            .disposed(by: disposeBag)

        paymentAmount
            .subscribe { [editing_workTimeAndPay] newValue in
                editing_workTimeAndPay.value.paymentAmount = newValue
            }
            .disposed(by: disposeBag)
        
        let workTimeAndPayInputValidation = saveButtonClicked
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
        
        workTimeAndPayNextable = workTimeAndPayInputValidation.asDriver(onErrorJustReturn: false)
        
        
        // MARK: Address input
        casting_addressInput = editing_addressInfo.asDriver(onErrorJustReturn: .mock)
        
        addressInformation
            .subscribe { [editing_addressInfo] newValue in
                editing_addressInfo.value.addressInfo = newValue
            }
            .disposed(by: disposeBag)
        
        let addressInputValidation = saveButtonClicked
            .map { [editing_addressInfo] _ in
                let object = editing_addressInfo.value
                
                return object.addressInfo != nil
            }
            
        addressInputNextable = addressInputValidation.asDriver(onErrorJustReturn: false)
        
        
        // MARK: Customer requirement
        casting_customerRequirement = editing_customerRequirement.asDriver(onErrorJustReturn: .mock)
        
        mealSupportNeeded
            .subscribe { [editing_customerRequirement] newValue in
                editing_customerRequirement.value.mealSupportNeeded = newValue
            }
            .disposed(by: disposeBag)
        
        toiletSupportNeeded
            .subscribe { [editing_customerRequirement] newValue in
                editing_customerRequirement.value.toiletSupportNeeded = newValue
            }
            .disposed(by: disposeBag)
        
        movingSupportNeeded
            .subscribe { [editing_customerRequirement] newValue in
                editing_customerRequirement.value.movingSupportNeeded = newValue
            }
            .disposed(by: disposeBag)
        
        // optional
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
        
        let customerRequirementInputValidation = saveButtonClicked
            .map { [editing_customerRequirement] _ in
                let requirement = editing_customerRequirement.value
                
                return requirement.mealSupportNeeded != nil &&
                requirement.toiletSupportNeeded != nil &&
                requirement.movingSupportNeeded != nil
            }
        
        customerRequirementNextable = customerRequirementInputValidation.asDriver(onErrorJustReturn: false)
        
        // MARK: Customer information
        casting_customerInformation = editing_customerInformation.asDriver(onErrorJustReturn: .mock)
        
        name
            .subscribe { [editing_customerInformation] newValue in
                editing_customerInformation.value.name = newValue
            }
            .disposed(by: disposeBag)
        
        gender
            .subscribe { [editing_customerInformation] newValue in
                editing_customerInformation.value.gender = newValue
            }
            .disposed(by: disposeBag)
        
        birthYear
            .subscribe { [editing_customerInformation] newValue in
                editing_customerInformation.value.birthYear = newValue
            }
            .disposed(by: disposeBag)
        
        careGrade
            .subscribe { [editing_customerInformation] newValue in
                editing_customerInformation.value.careGrade = newValue
            }
            .disposed(by: disposeBag)
        
        cognitionState
            .subscribe { [editing_customerInformation] newValue in
                editing_customerInformation.value.cognitionState = newValue
            }
            .disposed(by: disposeBag)
        
        // optional
        weight
            .subscribe { [editing_customerInformation] newValue in
                editing_customerInformation.value.weight = newValue
            }
            .disposed(by: disposeBag)
        
        deceaseDescription
            .subscribe { [editing_customerInformation] newValue in
                editing_customerInformation.value.deceaseDescription = newValue
            }
            .disposed(by: disposeBag)
        
        let customerInformationInputValidation = saveButtonClicked
            .map { [editing_customerInformation] _ in
                let customerInfo = editing_customerInformation.value
                
                return !customerInfo.name.isEmpty &&
                !customerInfo.birthYear.isEmpty &&
                customerInfo.careGrade != nil &&
                customerInfo.cognitionState != nil
            }
        
        customerInformationNextable = customerInformationInputValidation.asDriver(onErrorJustReturn: false)
        
        // MARK: Application detail
        casting_applicationDetail = editing_applicationDetail.asDriver(onErrorJustReturn: .mock)
        
        experiencePreferenceType
            .subscribe { [editing_applicationDetail] newValue in
                editing_applicationDetail.value.experiencePreferenceType = newValue
            }
            .disposed(by: disposeBag)
        
        applyType
            .subscribe { [editing_applicationDetail] (applyType, isActive) in
                editing_applicationDetail.value.applyType[applyType] = isActive
            }
            .disposed(by: disposeBag)
        
        applyDeadlineType
            .subscribe { [editing_applicationDetail] newValue in
                editing_applicationDetail.value.applyDeadlineType = newValue
            }
            .disposed(by: disposeBag)
        
        deadlineDate
            .subscribe { [editing_applicationDetail] newValue in
                editing_applicationDetail.value.deadlineDate = newValue
            }
            .disposed(by: disposeBag)
        
        // optional
        deadlineString = deadlineDate
            .compactMap { $0 }
            .map { $0.convertDateToString() }
            .asDriver(onErrorJustReturn: "")
        
         
        let applicationDetailInputValidation = saveButtonClicked
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
        
        applicationDetailViewNextable = applicationDetailInputValidation.asDriver(onErrorJustReturn: false)
        
        editViewExitButtonClicked
            .subscribe(onNext: { [weak self] in
                self?.editPostCoordinator?.coordinatorDidFinish()
            })
            .disposed(by: disposeBag)
        
        let inputValidationResult = Observable
            .zip(
                workTimeAndPayInputValidation.map({
                    (RegisterRecruitmentPostInputSection.workTimeAndPay, $0)
                }),
                addressInputValidation.map({
                    (RegisterRecruitmentPostInputSection.addressInfo, $0)
                }),
                customerRequirementInputValidation.map({
                    (RegisterRecruitmentPostInputSection.customerRequirement, $0)
                }),
                customerInformationInputValidation.map({
                    (RegisterRecruitmentPostInputSection.customerInformation, $0)
                }),
                applicationDetailInputValidation.map({
                    (RegisterRecruitmentPostInputSection.applicationDetail, $0)
                })
            )
            .map { (v1, v2, v3, v4, v5) -> RegisterRecruitmentPostInputSection? in
                
                for validation in [v1, v2, v3, v4, v5] {
                    if !validation.1 {
                        return validation.0
                    }
                }
                return nil
            }
            .share()
        
        
        let inputValidationSuccess = inputValidationResult.filter { $0 == nil }
        let inputValidationFailure = inputValidationResult.compactMap { $0 }
        
        let editingRequestResult = mapEndLoading(mapStartLoading(inputValidationSuccess)
            .flatMap { [weak self] _ -> Single<Result<Void, DomainError>> in
                guard let self else { return .never() }
                
                return recruitmentPostUseCase.editRecruitmentPost(
                    id: id,
                    inputs: .init(
                        workTimeAndPay: editing_workTimeAndPay.value,
                        customerRequirement: editing_customerRequirement.value,
                        customerInformation: editing_customerInformation.value,
                        applicationDetail: editing_applicationDetail.value,
                        addressInfo: editing_addressInfo.value
                    )
                )
            })
            .share()
        
        let editingRequestSuccess = editingRequestResult.compactMap { $0.value }
        let editingRequestFailure = editingRequestResult.compactMap { $0.error }
        
        editingRequestSuccess
            .subscribe { [weak self] _ in
                guard let self else { return }
                
                // 성공적으로 수정됨
                self.editPostCoordinator?
                    .coordinatorDidFinishWithSnackBar(ro: .init(titleText: "공고가 수정되었어요."))
            }
            .disposed(by: disposeBag)
        
        Observable
            .merge(
                workTimeAndPayInputValidation.map({
                    (RegisterRecruitmentPostInputSection.workTimeAndPay, $0)
                }),
                addressInputValidation.map({
                    (RegisterRecruitmentPostInputSection.addressInfo, $0)
                }),
                customerRequirementInputValidation.map({
                    (RegisterRecruitmentPostInputSection.customerRequirement, $0)
                }),
                customerInformationInputValidation.map({
                    (RegisterRecruitmentPostInputSection.customerInformation, $0)
                }),
                applicationDetailInputValidation.map({
                    (RegisterRecruitmentPostInputSection.applicationDetail, $0)
                })
            )
            .subscribe { [weak self] inputSection, isValid in
                self?.validationStateQueue.sync { [weak self] in
                    self?.validationState[inputSection] = isValid
                }
            }
            .disposed(by: disposeBag)
        
        // 최초 데이터를 가져옵니다.
        let recruitmentDetailRequestResult = recruitmentPostUseCase
            .getPostDetailForCenter(id: id)
        
        let recruitmentDetailRequestSuccess = recruitmentDetailRequestResult.compactMap { $0.value }
        let recruitmentDetailRequestFailure = recruitmentDetailRequestResult.compactMap { $0.error }
        
        // 인풋이 유효하지 않은 경우
        self.requestSaveFailure = Observable.merge(
            inputValidationFailure.map { $0.alertMessaage },
            editingRequestFailure.map { $0.message },
            recruitmentDetailRequestFailure.asObservable().map { $0.message }
        )
        .map({ message in
            DefaultAlertContentVO(title: "공고 수정 오류", message: message)
        })
        .asDriver(onErrorJustReturn: .default)
        
        
        recruitmentDetailRequestSuccess
            .subscribe(onSuccess: { [weak self] bundle in
                guard let self else { return }
                
                editing_addressInfo.accept(bundle.addressInfo)
                editing_applicationDetail.accept(bundle.applicationDetail)
                editing_customerInformation.accept(bundle.customerInformation)
                editing_customerRequirement.accept(bundle.customerRequirement)
                editing_workTimeAndPay.accept(bundle.workTimeAndPay)
                
            })
            .disposed(by: disposeBag)
    }

}
