//
//  WorkerProfileViewModel.swift
//  WorkerFeature
//
//  Created by choijunios on 8/10/24.
//

import UIKit
import PresentationCore
import BaseFeature
import Domain
import Repository
import Core


import RxSwift
import RxCocoa

/// 자신의 프로필을 확인하는 경우가 아닌 센터측에서 요양보호사를 보는 경우
protocol OtherWorkerProfileViewModelable: WorkerProfileViewModelable {
    
    var phoneCallButtonClicked: PublishRelay<Void> { get }
}

class WorkerProfileViewModel: BaseViewModel, OtherWorkerProfileViewModelable {
    
    // Init
    let id: String
    
    // Injected
    @Injected var cacheRepository: CacheRepository
    @Injected var workerProfileUseCase: WorkerProfileUseCase
    
    // Navigation
    var exitPage: (() -> ())?
    
    // Input(Rendering)
    var viewWillAppear: PublishRelay<Void> = .init()
    var exitButtonClicked: PublishRelay<Void> = .init()
    var phoneCallButtonClicked: PublishRelay<Void> = .init()
    
    // Output
    var uploadSuccess: Driver<Void>?
    
    var profileRenderObject: Driver<WorkerProfileRenderObject>?
    private let rederingState: BehaviorRelay<WorkerProfileRenderObject> = .init(value: .createRO(isMyProfile: true, vo: .mock))
    var displayingImage: RxCocoa.Driver<UIImage?>?
    
    // Image
    private let imageDownLoadScheduler = ConcurrentDispatchQueueScheduler(qos: .userInitiated)
    
    // Editing & State
    var willSubmitImage: UIImage?
    var editingState: WorkerProfileStateObject = .default
    var currentState: WorkerProfileStateObject = .default
    
    let disposbag: DisposeBag = .init()
    
    init(id: String) {
        
        self.id = id
        
        super.init()
        
        // Input(Rendering)
        let fetchedProfileVOResult = mapEndLoading(mapStartLoading(viewWillAppear.asObservable())
                .flatMap { [unowned self] _ in
                    fetchProfileVO()
                })
                .share()
        
        let fetchedProfileVOSuccess = fetchedProfileVOResult
            .compactMap { $0.value }
            .map { [weak self] vo in
                
                if let self {
                    currentState.experienceYear = vo.expYear
                    currentState.introduce = vo.introductionText
                    currentState.isJobFinding = vo.isLookingForJob
                    currentState.lotNumberAddress = vo.address.jibunAddress
                    currentState.roadNameAddress = vo.address.roadAddress
                    currentState.speciality = vo.specialty
                }
                
                return vo
            }
        
        displayingImage = fetchedProfileVOSuccess
            .compactMap { $0.profileImageInfo }
            .observe(on: imageDownLoadScheduler)
            .flatMap { [cacheRepository] downloadInfo in
                cacheRepository
                    .getImage(imageInfo: downloadInfo)
            }
            .map({ image -> UIImage? in
                image
            })
            .asDriver(onErrorDriveWith: .never())
        
        exitButtonClicked
            .unretained(self)
            .subscribe(onNext: { (obj, _) in
                obj.exitPage?()
            })
            .disposed(by: disposbag)
        
        phoneCallButtonClicked
            .withLatestFrom(fetchedProfileVOSuccess)
            .subscribe(onNext: { profileVO in
                
                let phoneNumber = profileVO.phoneNumber
                
                if let phoneURL = URL(string: "tel://\(phoneNumber)"), UIApplication.shared.canOpenURL(phoneURL) {
                            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
                        }
            })
            .disposed(by: disposbag)
        
        fetchedProfileVOSuccess
            .asObservable()
            .map({ vo in
                WorkerProfileRenderObject.createRO(isMyProfile: false, vo: vo)
            })
            .bind(to: rederingState)
            .disposed(by: disposbag)
        
        profileRenderObject = rederingState.asDriver(onErrorDriveWith: .never())
    }
    
    private func fetchProfileVO() -> Single<Result<WorkerProfileVO, DomainError>> {
        workerProfileUseCase
            .getProfile(mode: .otherProfile(id: id))
    }
}

