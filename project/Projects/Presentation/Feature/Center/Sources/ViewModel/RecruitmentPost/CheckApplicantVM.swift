//
//  CheckApplicantVM.swift
//  CenterFeature
//
//  Created by choijunios on 8/13/24.
//

import UIKit
import DSKit
import PresentationCore
import Domain
import BaseFeature
import ConcreteRepository


import RxSwift
import RxCocoa

public protocol CheckApplicantViewModelable: BaseViewModel {
    // Input
    var requestpostApplicantVO: PublishRelay<Void> { get }
    var exitButtonClicked: PublishRelay<Void> { get }
    
    
    // Output
    var postApplicantVO: Driver<[PostApplicantVO]>? { get }
    var postCardVO: Driver<CenterEmployCardVO>? { get }
    
    func createApplicantCardVM(vo: PostApplicantVO) -> ApplicantCardVM
}

public class CheckApplicantVM: BaseViewModel, CheckApplicantViewModelable {
    
    // Init
    let postId: String
    weak var coorindator: CheckApplicantCoordinatable?
    let recruitmentPostUseCase: RecruitmentPostUseCase
    
    public var exitButtonClicked: PublishRelay<Void> = .init()
    public var requestpostApplicantVO: PublishRelay<Void> = .init()
    
    
    public var postApplicantVO: Driver<[PostApplicantVO]>?
    public var postCardVO: Driver<CenterEmployCardVO>?
    
    public init(postId: String, coorindator: CheckApplicantCoordinatable?, recruitmentPostUseCase: RecruitmentPostUseCase) {
        self.postId = postId
        self.recruitmentPostUseCase = recruitmentPostUseCase
        self.coorindator = coorindator
        
        super.init()
        
        exitButtonClicked
            .subscribe(onNext: { [weak self] _ in
                
                self?.coorindator?.taskFinished()
            })
            .disposed(by: disposeBag)
        
        // Input
        let requestScreenDataResult = requestpostApplicantVO
            .flatMap { [recruitmentPostUseCase] _ in
                recruitmentPostUseCase.getPostApplicantScreenData(id: postId)
            }
            .share()
            
        let requestScreenDataSuccess = requestScreenDataResult.compactMap { $0.value }.share()
        let requestScreenDataFailure = requestScreenDataResult.compactMap { $0.error }
        
        // Output
        postApplicantVO = requestScreenDataSuccess
            .map({ screenData in screenData.applicantList })
            .asDriver(onErrorDriveWith: .never())
        
        
        postCardVO = requestScreenDataSuccess
            .map({ screenData in screenData.summaryCardVO })
            .asDriver(onErrorDriveWith: .never())
        
        
        requestScreenDataFailure
            .map { error in
                
                DefaultAlertContentVO(
                    title: "지원자 확인 오류",
                    message: error.message
                )
            }
            .subscribe(alert)
            .disposed(by: disposeBag)
    }
    
    public func createApplicantCardVM(vo: PostApplicantVO) -> ApplicantCardVM {
        .init(vo: vo, coordinator: coorindator)
    }
}


// MARK: ApplicantCardVM
public class ApplicantCardVM: ApplicantCardViewModelable {
    @Injected var cacheRepository: CacheRepository
    
    // Init
    let id: String
    weak var coordinator: CheckApplicantCoordinatable?
    
    public var showProfileButtonClicked: PublishRelay<Void> = .init()
    public var employButtonClicked: PublishRelay<Void> = .init()
    public var staredThisWorker: PublishRelay<Bool> = .init()
    
    public var renderObject: Driver<ApplicantCardRO>?
    public var displayingImage: RxCocoa.Driver<UIImage>?
    
    private let imageDownLoadScheduler = ConcurrentDispatchQueueScheduler(qos: .userInitiated)
    
    let disposeBag = DisposeBag()
    
    public init(vo: PostApplicantVO, coordinator: CheckApplicantCoordinatable?) {
        self.id = vo.workerId
        self.coordinator = coordinator
        
        // MARK: RenderObject
        let publishRelay: BehaviorRelay<ApplicantCardRO> = .init(value: .mock)
        renderObject = publishRelay.asDriver(onErrorJustReturn: .mock)
        
        if let imageInfo = vo.imageInfo {
            
            displayingImage = cacheRepository
                .getImage(imageInfo: imageInfo)
                .subscribe(on: imageDownLoadScheduler)
                .asDriver(onErrorDriveWith: .never())
        }
        
        publishRelay
            .accept(ApplicantCardRO.create(vo: vo))
        
        // MARK: 버튼 처리
        showProfileButtonClicked
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                coordinator?.showWorkerProfileScreen(
                    profileId: id
                )
            })
            .disposed(by: disposeBag)
    }
}
