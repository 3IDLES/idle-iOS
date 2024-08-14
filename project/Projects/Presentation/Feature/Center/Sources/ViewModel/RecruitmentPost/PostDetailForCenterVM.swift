//
//  PostDetailForCenterVM.swift
//  CenterFeature
//
//  Created by choijunios on 8/14/24.
//

import Foundation
import RxSwift
import RxCocoa
import Entity
import PresentationCore
import UseCaseInterface
import BaseFeature

public protocol PostDetailViewModelable:
    AnyObject,
    PostDetailDisplayingViewModelable
{
    
    var workerEmployCardVO: Driver<WorkerEmployCardVO>? { get }
    var requestDetailFailure: Driver<DefaultAlertContentVO>? { get }
    var applicantCount: Int? { get }
    
    // Input
    var postEditButtonClicked: PublishRelay<Void> { get }
    var exitButtonClicked: PublishRelay<Void> { get }
    var checkApplicationButtonClicked: PublishRelay<Void> { get }
    var viewWillAppear: PublishRelay<Void> { get }
}

public class PostDetailForCenterVM: PostDetailViewModelable {
    
    weak var coordinator: PostDetailForCenterCoordinator?
    
    // MARK: DetailVC Interaction
    public var applicantCount: Int?
    public var workerEmployCardVO: RxCocoa.Driver<Entity.WorkerEmployCardVO>?
    public var requestDetailFailure: RxCocoa.Driver<Entity.DefaultAlertContentVO>?
    
    public var postEditButtonClicked: RxRelay.PublishRelay<Void> = .init()
    public var exitButtonClicked: RxRelay.PublishRelay<Void> = .init()
    public var checkApplicationButtonClicked: RxRelay.PublishRelay<Void> = .init()
    public var viewWillAppear: RxRelay.PublishRelay<Void> = .init()
    
    // MARK: fetched
    private let fetched_workTimeAndPay: BehaviorRelay<WorkTimeAndPayStateObject> = .init(value: .init())
    private let fetched_customerRequirement: BehaviorRelay<CustomerRequirementStateObject> = .init(value: .init())
    private let fetched_customerInformation: BehaviorRelay<CustomerInformationStateObject> = .init(value: .init())
    private let fetched_applicationDetail: BehaviorRelay<ApplicationDetailStateObject> = .init(value: .init())
    private let fetched_addressInfo: BehaviorRelay<AddressInputStateObject> = .init(value: .init())
    
    // MARK: Casting
    public var casting_workTimeAndPay: Driver<WorkTimeAndPayStateObject>
    public var casting_customerRequirement: Driver<CustomerRequirementStateObject>
    public var casting_customerInformation: Driver<CustomerInformationStateObject>
    public var casting_applicationDetail: Driver<ApplicationDetailStateObject>
    public var casting_addressInput: Driver<AddressInputStateObject>
    
    
    // MARK: 모든 섹션의 유효성 확인
    private let validationStateQueue = DispatchQueue.global(qos: .userInteractive)
    private var validationState: [RegisterRecruitmentPostInputSection: Bool] = {
        var dict: [RegisterRecruitmentPostInputSection: Bool] = [:]
        RegisterRecruitmentPostInputSection.allCases.forEach { section in
            dict[section] = false
        }
        return dict
    }()
    
    let disposeBag = DisposeBag()
    
    init(
            id: String,
            applicantCount: Int?,
            coordinator: PostDetailForCenterCoordinator?,
            recruitmentPostUseCase: RecruitmentPostUseCase
        )
    {
        
        self.coordinator = coordinator
        self.applicantCount = applicantCount
        
        casting_workTimeAndPay = fetched_workTimeAndPay.asDriver()
        casting_customerRequirement = fetched_customerRequirement.asDriver()
        casting_customerInformation = fetched_customerInformation.asDriver()
        casting_applicationDetail = fetched_applicationDetail.asDriver()
        casting_addressInput = fetched_addressInfo.asDriver()
        
        // MARK: Post card
        
        
        
        // MARK: Detail View
        let fetchPostDetailResult = viewWillAppear
            .flatMap { [recruitmentPostUseCase] _ in
                recruitmentPostUseCase
                    .getPostDetailForCenter(id: id)
            }
            .share()
        
        let fetchPostDetailSuccess = fetchPostDetailResult.compactMap { $0.value }
        let fetchPostDetailFailure = fetchPostDetailResult.compactMap { $0.error }
         
        requestDetailFailure = fetchPostDetailFailure
            .map({ error in
                DefaultAlertContentVO(
                    title: "공고 상세보기 오류",
                    message: error.message
                )
            })
            .asDriver(onErrorJustReturn: .default)
        
        workerEmployCardVO = fetchPostDetailSuccess
            .map { [weak self] bundle in
                guard let self else { return .default }
                
                fetched_workTimeAndPay.accept(bundle.workTimeAndPay)
                fetched_customerRequirement.accept(bundle.customerRequirement)
                fetched_customerInformation.accept(bundle.customerInformation)
                fetched_applicationDetail.accept(bundle.applicationDetail)
                fetched_addressInfo.accept(bundle.addressInfo)
                
                // 남은 일수
                var leftDay: Int? = nil
                let calendar = Calendar.current
                let currentDate = Date()
                
                if fetched_applicationDetail.value.applyDeadlineType == .specificDate, let deadlineDate = fetched_applicationDetail.value.deadlineDate {
                    
                    let component = calendar.dateComponents([.day], from: currentDate, to: deadlineDate)
                    leftDay = component.day
                }
                
                // 초보가능 여부
                let isBeginnerPossible = fetched_applicationDetail.value.experiencePreferenceType == .beginnerPossible
                
                // 제목(=도로명주소)
                let title = fetched_addressInfo.value.addressInfo?.roadAddress.emptyDefault("위치정보 표기 오류") ?? ""
                
                // 도보시간
                let timeTakenForWalk = "도보 n분"
                
                // 생년
                let birthYear = Int(fetched_customerInformation.value.birthYear) ?? 1970
                let currentYear = calendar.component(.year, from: currentDate)
                let targetAge = currentYear - birthYear + 1
                
                // 요양등급
                let targetLavel: Int = (fetched_customerInformation.value.careGrade?.rawValue ?? 0)+1
                
                // 성별
                let targetGender = fetched_customerInformation.value.gender
                
                // 근무 요일
                let days = fetched_workTimeAndPay.value.selectedDays.filter { (_, value) in
                    value
                }.map { (key, _) in
                    key
                }
                
                // 근무 시작, 종료시간
                let startTime = fetched_workTimeAndPay.value.workStartTime?.convertToStringForButton() ?? "00:00"
                let workEndTime = fetched_workTimeAndPay.value.workEndTime?.convertToStringForButton() ?? "00:00"
                
                // 급여타입및 양
                let paymentType = fetched_workTimeAndPay.value.paymentType ?? .hourly
                let paymentAmount = fetched_workTimeAndPay.value.paymentAmount
                
                return WorkerEmployCardVO(
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
            }
            .asDriver(onErrorJustReturn: .default)
            
        
        postEditButtonClicked
            .subscribe(onNext: { [weak self] _ in
                self?.coordinator?.showPostEditScreen(postId: id)
            })
            .disposed(by: disposeBag)
        
        exitButtonClicked
            .subscribe(onNext: { [weak self] _ in
                self?.coordinator?.coordinatorDidFinish()
            })
            .disposed(by: disposeBag)
        
        checkApplicationButtonClicked
            .subscribe(onNext: { _ in
                
            })
            .disposed(by: disposeBag)
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
}
