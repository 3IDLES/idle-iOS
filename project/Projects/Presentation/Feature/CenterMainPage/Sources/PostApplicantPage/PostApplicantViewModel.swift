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
import Repository
import Core


import RxSwift
import RxCocoa

protocol PostApplicantViewModelable: BaseViewModel {
    // Input
    var requestpostApplicantVO: PublishRelay<Void> { get }
    var exitButtonClicked: PublishRelay<Void> { get }
    
    
    // Output
    var postApplicantVO: Driver<[PostApplicantVO]>? { get }
    var postCardVO: Driver<CenterEmployCardVO>? { get }
    
    var createCellViewModel: ((PostApplicantVO) -> ApplicantCardViewModelable)? { get }
}

class PostApplicantViewModel: BaseViewModel, PostApplicantViewModelable {
    
    @Injected var recruitmentPostUseCase: RecruitmentPostUseCase
    
    var createCellViewModel: ((PostApplicantVO) -> ApplicantCardViewModelable)?
    var exitPage: (() -> ())?
    
    // Init
    let postId: String
    
    var exitButtonClicked: PublishRelay<Void> = .init()
    var requestpostApplicantVO: PublishRelay<Void> = .init()
    
    var postApplicantVO: Driver<[PostApplicantVO]>?
    var postCardVO: Driver<CenterEmployCardVO>?
    
    init(postId: String) {
        
        self.postId = postId
        
        super.init()
        
        exitButtonClicked
            .unretained(self)
            .subscribe(onNext: { (obj, _) in
                obj.exitPage?()
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
}


// MARK: ApplicantCardVM
class ApplicantCardVM: ApplicantCardViewModelable {
    @Injected var cacheRepository: CacheRepository
    
    // Navigation
    var presentApplicantDetail: ((String) -> ())?
    
    // Init
    let id: String
    
    var showProfileButtonClicked: PublishRelay<Void> = .init()
    var employButtonClicked: PublishRelay<Void> = .init()
    var staredThisWorker: PublishRelay<Bool> = .init()
    
    var renderObject: Driver<ApplicantCardRO>?
    var displayingImage: RxCocoa.Driver<UIImage>?
    
    private let imageDownLoadScheduler = ConcurrentDispatchQueueScheduler(qos: .userInitiated)
    
    let disposeBag = DisposeBag()
    
    init(vo: PostApplicantVO) {
        self.id = vo.workerId
        
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
            .unretained(self)
            .subscribe(onNext: { (obj, _) in
                obj.presentApplicantDetail?(obj.id)
            })
            .disposed(by: disposeBag)
    }
}
