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
    PostDetailDisplayingViewModelable, DefaultAlertOutputable
{
    // Output
    var applicantCountText: Driver<String>? { get }
    var workerEmployCardVO: Driver<WorkerEmployCardVO>? { get }
    var requestDetailFailure: Driver<DefaultAlertContentVO>? { get }
    var showOptionSheet: Driver<PostState>? { get }
    
    
    // Input
    /// 옵션버튼
    var optionButtonClicked: PublishRelay<Void> { get }
    
    /// 나가기 버튼
    var exitButtonClicked: PublishRelay<Void> { get }
    
    /// 지원자 확인
    var checkApplicationButtonClicked: PublishRelay<Void> { get }
    
    /// 공고 삭제
    var removePostButtonClicked: PublishRelay<Void> { get }
    
    /// 공고 종료
    var closePostButtonClicked: PublishRelay<Void> { get }
    
    /// 요양보호사가 보는 화면으로 보기
    var showAsWorkerButtonClicked: PublishRelay<Void> { get }
    
    /// 공고 수정버튼
    var postEditButtonClicked: PublishRelay<Void> { get }
    
    /// viewWillAppear
    var viewWillAppear: PublishRelay<Void> { get }
}

public class PostDetailForCenterVM: PostDetailViewModelable {
    
    // Init
    let postId: String
    let postState: PostState
    weak var coordinator: PostDetailForCenterCoordinator?
    let recruitmentPostUseCase: RecruitmentPostUseCase
    
    // MARK: DetailVC Interaction
    public var applicantCount: Int?
    public var workerEmployCardVO: RxCocoa.Driver<Entity.WorkerEmployCardVO>?
    public var requestDetailFailure: RxCocoa.Driver<Entity.DefaultAlertContentVO>?
    public var showOptionSheet: RxCocoa.Driver<Entity.PostState>?
    public var alert: RxCocoa.Driver<Entity.DefaultAlertContentVO>?
    
    public let postEditButtonClicked: RxRelay.PublishRelay<Void> = .init()
    public let exitButtonClicked: RxRelay.PublishRelay<Void> = .init()
    public let checkApplicationButtonClicked: RxRelay.PublishRelay<Void> = .init()
    public let optionButtonClicked: RxRelay.PublishRelay<Void> = .init()
    public let removePostButtonClicked: RxRelay.PublishRelay<Void> = .init()
    public let closePostButtonClicked: RxRelay.PublishRelay<Void> = .init()
    public let showAsWorkerButtonClicked: RxRelay.PublishRelay<Void> = .init()
    
    public let viewWillAppear: RxRelay.PublishRelay<Void> = .init()
    
    
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
    
    // MARK: ETC
    public let applicantCountText: Driver<String>?
    
    let disposeBag = DisposeBag()
    
    init(
            postId: String,
            postState: PostState,
            coordinator: PostDetailForCenterCoordinator?,
            recruitmentPostUseCase: RecruitmentPostUseCase
        )
    {
        self.postId = postId
        self.postState = postState
        self.coordinator = coordinator
        self.recruitmentPostUseCase = recruitmentPostUseCase
        
        casting_workTimeAndPay = fetched_workTimeAndPay.asDriver()
        casting_customerRequirement = fetched_customerRequirement.asDriver()
        casting_customerInformation = fetched_customerInformation.asDriver()
        casting_applicationDetail = fetched_applicationDetail.asDriver()
        casting_addressInput = fetched_addressInfo.asDriver()
        
        // MARK: 지원자 수 조회
        let getApplicantCountResult = recruitmentPostUseCase
            .getPostApplicantCount(id: postId)
            .asObservable()
            .share()
        
        let getApplicantCountSuccess = getApplicantCountResult.compactMap { $0.value }
        let getApplicantCountFailure = getApplicantCountResult.compactMap { $0.error }
        
        applicantCountText = Observable
            .merge(
                getApplicantCountSuccess.map { cnt in "지원자 \(cnt)명 조회" }.asObservable(),
                getApplicantCountFailure.map { error in
                    printIfDebug("지원자수를 가져올 수 없음 \(error.message)")
                    return "지원자 수 조회 실패"
                }.asObservable()
            )
            .asDriver(onErrorDriveWith: .never())
        
        // MARK: Detail View
        let fetchPostDetailResult = viewWillAppear
            .flatMap { [recruitmentPostUseCase] _ in
                recruitmentPostUseCase
                    .getPostDetailForCenter(id: postId)
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
        
        
        // MARK: 요양보호사 버전 카드뷰
        workerEmployCardVO = fetchPostDetailSuccess
            .map { [weak self] bundle in
                guard let self else { return .default }
                
                fetched_workTimeAndPay.accept(bundle.workTimeAndPay)
                fetched_customerRequirement.accept(bundle.customerRequirement)
                fetched_customerInformation.accept(bundle.customerInformation)
                fetched_applicationDetail.accept(bundle.applicationDetail)
                fetched_addressInfo.accept(bundle.addressInfo)
                
                return WorkerEmployCardVO.create(
                    workTimeAndPay: fetched_workTimeAndPay.value,
                    customerRequirement: fetched_customerRequirement.value,
                    customerInformation: fetched_customerInformation.value,
                    applicationDetail: fetched_applicationDetail.value,
                    addressInfo: fetched_addressInfo.value
                )
            }
            .asDriver(onErrorJustReturn: .default)
            
        
        // MARK: 버튼 처리
        
        // 옵션스크린 표출
        showOptionSheet = optionButtonClicked
            .map { _ in postState }
            .asDriver(onErrorDriveWith: .never())
        
        // 공고 수정 버튼
        postEditButtonClicked
            .subscribe(onNext: { [weak self] _ in
                self?.coordinator?.showPostEditScreen(postId: postId)
            })
            .disposed(by: disposeBag)
        
        // 채용종료 버튼
        let closePostResult = closePostButtonClicked
            .flatMap { [recruitmentPostUseCase] _ in
                recruitmentPostUseCase.closePost(id: postId)
            }
            .share()
        
        let closePostSuccess = closePostResult.compactMap { $0.value }
        let closePostFailure = closePostResult.compactMap { $0.error }
        
        
        // 공고삭제 버튼
        let removePostResult = removePostButtonClicked
            .flatMap { [recruitmentPostUseCase] _ in
                recruitmentPostUseCase.removePost(id: postId)
            }
            .share()
        
        let removePostSuccess = removePostResult.compactMap { $0.value }
        let removePostFailure = removePostResult.compactMap { $0.error }
        
        Observable
            .merge(closePostSuccess, removePostSuccess)
            .subscribe(onNext: { [weak self] _ in
                self?.coordinator?.coordinatorDidFinish()
            })
            .disposed(by: disposeBag)
        
        
        self.alert = Observable
            .merge(removePostFailure, closePostFailure)
            .map { error in
                DefaultAlertContentVO(
                    title: "공고 상세화면 오류",
                    message: error.message
                )
            }
            .asDriver(onErrorJustReturn: .default)
        
        
        // 요양보호사 화면 보기 버튼
        showAsWorkerButtonClicked
            .subscribe(onNext: { [weak self] _ in
                
                // 코디네이터 이용
                
            })
            .disposed(by: disposeBag)
        
        // 나가기 버튼
        exitButtonClicked
            .subscribe(onNext: { [weak self] _ in
                self?.coordinator?.coordinatorDidFinish()
            })
            .disposed(by: disposeBag)
        
        // 지원자확인 버튼
        checkApplicationButtonClicked
            .subscribe(onNext: { [weak self] _ in
                self?.coordinator?.showCheckApplicantScreen(postId: postId)
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
