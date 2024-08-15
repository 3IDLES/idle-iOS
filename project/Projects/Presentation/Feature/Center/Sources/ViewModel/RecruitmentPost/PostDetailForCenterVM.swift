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
                
                return WorkerEmployCardVO.create(
                    postId: id,
                    workTimeAndPay: fetched_workTimeAndPay.value,
                    customerRequirement: fetched_customerRequirement.value,
                    customerInformation: fetched_customerInformation.value,
                    applicationDetail: fetched_applicationDetail.value,
                    addressInfo: fetched_addressInfo.value
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
            .subscribe(onNext: { [weak self] _ in
                self?.coordinator?.showCheckApplicantScreen(postId: id)
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
