//
//  WorkerProfileViewModel.swift
//  WorkerFeature
//
//  Created by choijunios on 7/22/24.
//

import UIKit
import PresentationCore
import RxSwift
import RxCocoa
import DSKit
import Entity
import UseCaseInterface

public class WorkerMyProfileViewModel: WorkerProfileEditViewModelable {
    
    public weak var coordinator: WorkerProfileCoordinator?
    
    let workerProfileUseCase: WorkerProfileUseCase
    
    // Input(Editing)
    var requestUpload: PublishRelay<Void> = .init()
    var editingImage: PublishRelay<UIImage> = .init()
    var editingIsJobFinding: PublishRelay<Bool> = .init()
    var editingExpYear: PublishRelay<Int> = .init()
    var editingAddress: PublishRelay<AddressInformation> = .init()
    var editingIntroduce: PublishRelay<String> = .init()
    var editingSpecialty: PublishRelay<String> = .init()
    
    // Input(Rendering)
    public var viewWillAppear: PublishRelay<Void> = .init()
    
    public var exitButtonClicked: RxRelay.PublishRelay<Void> = .init()
    
    // Output
    var uploadSuccess: Driver<Void>?
    public var alert: Driver<Entity.DefaultAlertContentVO>?
    
    public var profileRenderObject: Driver<WorkerProfileRenderObject>?
    private let rederingState: BehaviorRelay<WorkerProfileRenderObject> = .init(value: .createRO(isMyProfile: true, vo: .mock))
    
    // Editing & State
    var willSubmitImageInfo: ImageUploadInfo?
    var editingState: WorkerProfileStateObject = .default
    var currentState: WorkerProfileStateObject = .default
    
    let disposbag: DisposeBag = .init()
    
    public init(
        coordinator: WorkerProfileCoordinator?,
        workerProfileUseCase: WorkerProfileUseCase
    ) {
        
        self.coordinator = coordinator
        self.workerProfileUseCase = workerProfileUseCase
        
        // Input(Rendering)
        let fetchedProfileVOResult = viewWillAppear
            .flatMap { [unowned self] _ in
                
                fetchProfileVO()
            }
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
            .asObservable()
            .map({ vo in
                WorkerProfileRenderObject.createRO(isMyProfile: true, vo: vo)
            })
            .bind(to: rederingState)
            .disposed(by: disposbag)
        
        exitButtonClicked
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.coordinatorDidFinish()
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
        
        let imageValidationFailure = imageValidationResult
            .filter { $0 == nil }
            .map { _ in
                DefaultAlertContentVO(
                    title: "이미지 선택 오류",
                    message: "지원하지 않는 이미지 형식입니다."
                )
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
        
        let editingRequestResult = requestUpload
            .flatMap { [unowned self] _ in
                requestUpload(editObject: editingState)
            }
            .share()
        
        let editingRequestFailure = editingRequestResult
            .compactMap { $0.error }
            .map { error in
                DefaultAlertContentVO(
                    title: "공고 수정 오류",
                    message: error.message
            )
        }
        
        uploadSuccess = editingRequestResult
            .compactMap { $0.value }
            .asDriver(onErrorRecover: { _ in fatalError() })
        
        alert = Observable
            .merge(
                imageValidationFailure,
                editingRequestFailure
            )
            .asDriver(onErrorJustReturn: .default)
        
        profileRenderObject = rederingState.asDriver(onErrorRecover: { _ in fatalError() })
    }
    
    private func fetchProfileVO() -> Single<Result<WorkerProfileVO, UserInfoError>> {
        workerProfileUseCase
            .getProfile(mode: .myProfile)
    }
    
    public func requestUpload(editObject: WorkerProfileStateObject) -> Single<Result<Void, UserInfoError>> {
        
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
        if let pngData = image.pngData() {
            return .init(data: pngData, ext: "PNG")
        } else if let jpegData = image.jpegData(compressionQuality: 1) {
            return .init(data: jpegData, ext: "JPEG")
        }
        return nil
    }
}

