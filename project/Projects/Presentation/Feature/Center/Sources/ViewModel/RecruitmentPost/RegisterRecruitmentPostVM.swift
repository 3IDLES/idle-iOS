//
//  RegisterRecruitmentPostVM.swift
//  CenterFeature
//
//  Created by choijunios on 8/2/24.
//

import Foundation
import Domain
import PresentationCore
import BaseFeature


import RxSwift
import RxCocoa


public enum RegisterRecruitmentPostInputSection: CaseIterable {
    case workTimeAndPay
    case customerRequirement
    case customerInformation
    case applicationDetail
    case addressInfo
    
    var alertMessaage: String {
        switch self {
        case .workTimeAndPay:
            "근무시간및 급여 입력 오류"
        case .customerRequirement:
            "주소정보 입력 오류"
        case .customerInformation:
            "고객 요구사항 입력 오류"
        case .applicationDetail:
            "지원 정보 입력오류"
        case .addressInfo:
            "근무지 정보 입력 오류"
        }
    }
}

public class RegisterRecruitmentPostVM: BaseViewModel, RegisterRecruitmentPostViewModelable {
    
    //Init
    let recruitmentPostUseCase: RecruitmentPostUseCase
    public weak var coordinator: (any PresentationCore.RegisterRecruitmentPostCoordinatable)?
    
    // MARK: Edit Screen
    public weak var editPostCoordinator: EditPostCoordinator?
    public var editViewExitButtonClicked: RxRelay.PublishRelay<Void> = .init()
    public var saveButtonClicked: RxRelay.PublishRelay<Void> = .init()
    public var requestSaveFailure: RxCocoa.Driver<DefaultAlertContentVO>?
    
    // MARK: OverView Screen
    public weak var postOverviewCoordinator: PostOverviewCoordinator?
    public var postEditButtonClicked: PublishRelay<Void> = .init()
    public var overViewExitButtonClicked: PublishRelay<Void> = .init()
    public var registerButtonClicked: PublishRelay<Void> = .init()
    public var overViewWillAppear: RxRelay.PublishRelay<Void> = .init()
    
    public var workerEmployCardVO: Driver<WorkerNativeEmployCardVO>?
    
    // MARK: register request
    public var postRegistrationSuccess: Driver<Void>?
    
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
    
    public var addressInputNextable: Driver<Bool>?
    
    // MARK: Work time and pay
    public var selectedDay: PublishRelay<(WorkDay, Bool)> = .init()
    public var workStartTime: PublishRelay<IdleDateComponent> = .init()
    public var workEndTime: PublishRelay<IdleDateComponent> = .init()
    public var paymentType: PublishRelay<PaymentType> = .init()
    public var paymentAmount: PublishRelay<String> = .init()
    
    
    public var workTimeAndPayNextable: Driver<Bool>?
    
    // MARK: Customer requirement
    public var mealSupportNeeded: PublishRelay<Bool> = .init()
    public var toiletSupportNeeded: PublishRelay<Bool> = .init()
    public var movingSupportNeeded: PublishRelay<Bool> = .init()
    public var dailySupportTypes: PublishRelay<(DailySupportType, Bool)> = .init()
    public var additionalRequirement: PublishRelay<String> = .init()
    
    public var customerRequirementNextable: Driver<Bool>?
    
    // MARK: Customer information
    public var name: PublishRelay<String> = .init()
    public var gender: PublishRelay<Gender> = .init()
    public var birthYear: PublishRelay<String> = .init()
    public var weight: PublishRelay<String> = .init()
    public var careGrade: PublishRelay<CareGrade> = .init()
    public var cognitionState: PublishRelay<CognitionDegree> = .init()
    public var deceaseDescription: PublishRelay<String> = .init()
    
    public var customerInformationNextable: Driver<Bool>?
    
    
    // MARK: Application detail
    public var experiencePreferenceType: PublishRelay<ExperiencePreferenceType> = .init()
    public var applyType: PublishRelay<(ApplyType, Bool)> = .init()
    public var applyDeadlineType: PublishRelay<ApplyDeadlineType> = .init()
    public var deadlineDate: BehaviorRelay<Date?> = .init(value: nil)
    
    public var deadlineString: Driver<String>?
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
        registerRecruitmentPostCoordinator: RegisterRecruitmentPostCoordinatable,
        recruitmentPostUseCase: RecruitmentPostUseCase
    ) {
        self.coordinator = registerRecruitmentPostCoordinator
        self.recruitmentPostUseCase = recruitmentPostUseCase
        
        super.init()
        
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
        
        let workTimeAndPayInputValidation = Observable.combineLatest(
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
        
        workTimeAndPayNextable = workTimeAndPayInputValidation.asDriver(onErrorJustReturn: false)
        
        
        // MARK: Address input
        casting_addressInput = editing_addressInfo.asDriver { _ in fatalError() }
        
        let addressInformation_changed = addressInformation
            .map { [editing_addressInfo] newValue in
                editing_addressInfo.value.addressInfo = newValue
            }
        
        let addressInputValidation = addressInformation_changed
            .map { [editing_addressInfo] _ in
                let object = editing_addressInfo.value
                
                return object.addressInfo != nil
            }
            
        addressInputNextable = addressInputValidation.asDriver(onErrorJustReturn: false)
        
        
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
        
        let customerRequirementInputValidation = Observable.combineLatest(
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
        
        customerRequirementNextable = customerRequirementInputValidation.asDriver(onErrorJustReturn: false)
        
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
        
        let careGrade_changed = careGrade
            .map { [editing_customerInformation] newValue in
                editing_customerInformation.value.careGrade = newValue
            }
        
        let cognitionState_changed = cognitionState
            .map { [editing_customerInformation] newValue in
                editing_customerInformation.value.cognitionState = newValue
            }
        
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
        
        let customerInformationInputValidation = Observable.combineLatest(
            name_changed,
            gender_changed,
            birthYear_changed,
            careGrade_changed,
            cognitionState_changed
        )
        .map { [editing_customerInformation] _ in
            let customerInfo = editing_customerInformation.value
            
            return !customerInfo.name.isEmpty && 
                   !customerInfo.birthYear.isEmpty &&
                   customerInfo.careGrade != nil &&
                   customerInfo.cognitionState != nil
        }
        
        customerInformationNextable = customerInformationInputValidation.asDriver(onErrorJustReturn: false)
        
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
        
        // optional
        deadlineString = deadlineDate
            .compactMap { $0 }
            .map { $0.convertDateToString() }
            .asDriver(onErrorJustReturn: "")
         
        let applicationDetailInputValidation = Observable.combineLatest(
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
        
        applicationDetailViewNextable = applicationDetailInputValidation.asDriver(onErrorJustReturn: false)
        
        // MARK: ----- Over view -----
        
        workerEmployCardVO = Observable<WorkerNativeEmployCardVO>
            .create { [
                editing_workTimeAndPay,
                editing_customerInformation,
                editing_customerRequirement,
                editing_applicationDetail,
                editing_addressInfo
            ] emitter in
                
                let vo = WorkerNativeEmployCardVO.create(
                    workTimeAndPay: editing_workTimeAndPay.value,
                    customerRequirement: editing_customerRequirement.value,
                    customerInformation: editing_customerInformation.value,
                    applicationDetail: editing_applicationDetail.value,
                    addressInfo: editing_addressInfo.value
                )
                
                emitter.onNext(vo)
                
                return Disposables.create { }
            }
            .asDriver(onErrorJustReturn: .mock)
        
        overViewWillAppear
            .subscribe(onNext: { [weak self] _ in
                // OverView가 나타날때 마다 상태를 업데이트 합니다.
                self?.fetchFromState()
            })
            .disposed(by: disposeBag)
        
        postEditButtonClicked
            .subscribe(onNext: { [weak self] _ in
                self?.coordinator?.showEditPostScreen()
            })
            .disposed(by: disposeBag)
        
        overViewExitButtonClicked
            .subscribe(onNext: { [weak self] _ in
                self?.postOverviewCoordinator?.coordinatorDidFinish()
            })
            .disposed(by: disposeBag)
        

        // MARK: ----- Edit -----
        editViewExitButtonClicked
            .subscribe(onNext: { [weak self] in
                self?.editPostCoordinator?.coordinatorDidFinish()
            })
            .disposed(by: disposeBag)
        
        let requestSaveResult = saveButtonClicked
            .flatMap { [weak self] _ in
                self?.allInputsValid() ?? .just(.default)
            }
            .share()
        
        let requestSaveSuccess = requestSaveResult.filter { $0 == nil }
        
        requestSaveSuccess
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                updateToState()
                
                // 저장이 성공적으로 완료되어 코디네이터와 뷰컨트롤러 종료
                editPostCoordinator?.coordinatorDidFinish()
            })
            .disposed(by: disposeBag)
        
        self.requestSaveFailure = requestSaveResult
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: .default)
            
        
        // MARK: -----------------
        let registerPostResult = registerButtonClicked
            .flatMap { [weak self] _ -> Single<Result<Void, DomainError>> in
                guard let self else { return .never() }
                
                self.showLoading.onNext(())
                
                // 공고를 등록합니다.
                let inputs = RegisterRecruitmentPostBundle(
                    workTimeAndPay: state_workTimeAndPay,
                    customerRequirement: state_customerRequirement,
                    customerInformation: state_customerInformation,
                    applicationDetail: state_applicationDetail,
                    addressInfo: state_addressInfo
                )
                
                return recruitmentPostUseCase
                    .registerRecruitmentPost(inputs: inputs)
            }
            .share()
        
        registerPostResult
            .subscribe(onNext: { [weak self] _ in
                
                self?.dismissLoading.onNext(())
            })
            .disposed(by: disposeBag)
        
        // 공고 등록 성공
        registerPostResult
            .compactMap { $0.value }
            .subscribe { [weak self] _ in
                self?.coordinator?.showRegisterCompleteScreen()
            }
            .disposed(by: disposeBag)
            
        
        registerPostResult
            .compactMap { $0.error }
            .subscribe(onNext: { [weak self] error in
                let alertVO = DefaultAlertContentVO(
                    title: "공고등록 오류",
                    message: error.message
                )
                
                self?.alert.onNext(alertVO)
            })
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

            // 최초로 데이터를 가져옵니다.
            fetchFromState()
    }
    
    public func allInputsValid() -> Single<DefaultAlertContentVO?> {
        
        Single<DefaultAlertContentVO?>.create { [weak self] single in
            
            self?.validationStateQueue.sync { [weak self, single] in
                
                guard let self else { return }
                
                for (key, value) in validationState {
                    
                    if !value {
                        single(.success(.init(title: "입력 정보 오류", message: key.alertMessaage)))
                    }
                }
                
                single(.success(nil))
            }
            
            return Disposables.create { }
        }
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
    
    public func showOverView() {
        coordinator?.showOverViewScreen()
    }
    
    public func exit() {
        coordinator?.registerFinished()
    }
}
