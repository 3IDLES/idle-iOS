//
//  WorkerProfileViewModel.swift
//  WorkerFeature
//
//  Created by choijunios on 7/22/24.
//

import UIKit
import PresentationCore
import DSKit
import Domain
import BaseFeature
import Repository
import Core


import RxSwift
import RxCocoa
import SDWebImageWebPCoder

protocol WorkerProfileViewModelable: BaseViewModel {
    
    // Input
    var viewWillAppear: PublishRelay<Void> { get }
    var exitButtonClicked: PublishRelay<Void> { get }
    
    // Output
    var displayingImage: Driver<UIImage?>? { get }
    var profileRenderObject: Driver<WorkerProfileRenderObject>? { get }
}

protocol WorkerProfileEditViewModelable: WorkerProfileViewModelable {
    
    var editButtonClicked: PublishRelay<Void> { get }
    var requestUpload: PublishRelay<Void> { get }
    var editingImage: PublishRelay<UIImage> { get }
    var editingIsJobFinding: PublishRelay<Bool> { get }
    var editingExpYear: PublishRelay<Int> { get }
    var editingAddress: PublishRelay<AddressInformation> { get }
    var editingIntroduce: PublishRelay<String> { get }
    var editingSpecialty: PublishRelay<String> { get }
    
    
    var uploadSuccess: Driver<Void>? { get }
}

class WorkerMyProfileViewModel: BaseViewModel, WorkerProfileEditViewModelable {

    // Injeced
    @Injected var cacheRepository: CacheRepository
    @Injected var workerProfileUseCase: WorkerProfileUseCase

    // Navigation
    var exitPage: (() -> ())?
    var presentEditPage: ((WorkerProfileEditViewModelable) -> ())?
    var presentDefaultAlert: ((DefaultAlertObject) -> ())?
    
    // Input(Editing)
    var editButtonClicked: PublishRelay<Void> = .init()
    var requestUpload: PublishRelay<Void> = .init()
    var editingImage: PublishRelay<UIImage> = .init()
    var editingIsJobFinding: PublishRelay<Bool> = .init()
    var editingExpYear: PublishRelay<Int> = .init()
    var editingAddress: PublishRelay<AddressInformation> = .init()
    var editingIntroduce: PublishRelay<String> = .init()
    var editingSpecialty: PublishRelay<String> = .init()
    
    // Input(Rendering)
    var viewWillAppear: PublishRelay<Void> = .init()
    
    var exitButtonClicked: RxRelay.PublishRelay<Void> = .init()
    
    // Output
    var uploadSuccess: Driver<Void>?
    
    var profileRenderObject: Driver<WorkerProfileRenderObject>?
    var displayingImage: Driver<UIImage?>?
    private let rederingState: BehaviorRelay<WorkerProfileRenderObject> = .init(value: .createRO(isMyProfile: true, vo: .mock))
    
    // Image
    private let imageDownLoadScheduler = ConcurrentDispatchQueueScheduler(qos: .userInitiated)
    
    // Editing & State
    var willSubmitImageInfo: ImageUploadInfo?
    var editingState: WorkerProfileStateObject = .default
    var currentState: WorkerProfileStateObject = .default
    
    let disposbag: DisposeBag = .init()
    
    override init() {
        
        super.init()
        
        editButtonClicked
            .unretained(self)
            .subscribe(onNext: { (obj, _) in
                
                obj.presentEditPage?(self)
            })
            .disposed(by: disposbag)
        
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
            
        
        fetchedProfileVOSuccess
            .map({ vo in
                WorkerProfileRenderObject
                    .createRO(isMyProfile: true, vo: vo)
            })
            .bind(to: rederingState)
            .disposed(by: disposbag)
        
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
            .asDriver(onErrorJustReturn: nil)
        
        exitButtonClicked
            .unretained(self)
            .subscribe(onNext: { (obj, _) in
                obj.exitPage?()
            })
            .disposed(by: disposbag)
        
        
        // Edit Input
        let imageValidationResult = editingImage
            .map { [weak self] image -> UIImage? in
                guard let imageInfo = self?.validateSelectedImage(image: image) else { return nil }
                printIfDebug("✅ 업로드 가능한 이미지 타입 \(imageInfo.ext)")
                self?.willSubmitImageInfo = imageInfo
                return image
            }
            .share()
        
        let imageValidationFailureAlert = imageValidationResult
            .filter { $0 == nil }
            .map { _ in
                DefaultAlertObject()
                    .setTitle("이미지 선택 오류")
                    .setDescription("지원하지 않는 이미지 형식입니다.")
            }
        
        editingIsJobFinding
            .subscribe { [weak self] isJobFinding in
                self?.editingState.isJobFinding = isJobFinding
            }
            .disposed(by: disposbag)
        
        editingExpYear
            .subscribe { [weak self] exp in
                self?.editingState.experienceYear = exp
            }
            .disposed(by: disposbag)

        
        editingAddress
            .subscribe(onNext: { [weak self] address in
                self?.editingState.roadNameAddress = address.roadAddress
                self?.editingState.lotNumberAddress = address.jibunAddress
            })
            .disposed(by: disposbag)
        
        editingIntroduce
            .subscribe { [weak self] introduce in
                self?.editingState.introduce = introduce
            }
            .disposed(by: disposbag)
        
        editingSpecialty
            .subscribe { [weak self] special in
                self?.editingState.speciality = special
            }
            .disposed(by: disposbag)
        
        let editingRequestResult = mapEndLoading(mapStartLoading(requestUpload.asObservable())
            .flatMap { [unowned self] _ in
                requestUpload(editObject: editingState)
            })
            .share()
        
        let editingRequestFailureAlert = editingRequestResult
            .compactMap { $0.error }
            .map { error in
                DefaultAlertObject()
                    .setTitle("공고 수정 오류")
                    .setDescription(error.message)
            }
        
        uploadSuccess = editingRequestResult
            .compactMap { $0.value }
            .asDriver(onErrorRecover: { _ in fatalError() })
        
        Observable
            .merge(
                imageValidationFailureAlert,
                editingRequestFailureAlert
            )
            .unretained(self)
            .subscribe { (obj, alertVO) in
                obj.presentDefaultAlert?(alertVO)
            }
            .disposed(by: disposbag)
            
        
        profileRenderObject = rederingState.asDriver(onErrorRecover: { _ in fatalError() })
    }
    
    private func fetchProfileVO() -> Single<Result<WorkerProfileVO, DomainError>> {
        workerProfileUseCase
            .getProfile(mode: .myProfile)
    }
    
    func requestUpload(editObject: WorkerProfileStateObject) -> Single<Result<Void, DomainError>> {
        
        var submitObject: WorkerProfileStateObject = .init()
        
        submitObject.experienceYear = (currentState.experienceYear != editObject.experienceYear) ? editObject.experienceYear : nil
        
        submitObject.introduce = (currentState.introduce != editObject.introduce) ? editObject.introduce : nil
        
        // Required
        submitObject.isJobFinding = editObject.isJobFinding ?? currentState.isJobFinding
        
        // Required
        submitObject.lotNumberAddress = editObject.lotNumberAddress ?? currentState.lotNumberAddress
        
        // Required
        submitObject.roadNameAddress = editObject.roadNameAddress ?? currentState.roadNameAddress
        
        submitObject.speciality = (currentState.speciality != editObject.speciality) ? editObject.speciality : nil
        
        return workerProfileUseCase
            .updateProfile(
                stateObject: submitObject,
                imageInfo: willSubmitImageInfo
            )
    }
    
    func validateSelectedImage(image: UIImage) -> ImageUploadInfo? {
        .create(image: image)
    }
}

