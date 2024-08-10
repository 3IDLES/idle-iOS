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

public class WorkerMyProfileViewModel: WorkerProfileEditViewModelable {
    
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
    
    // Output
    var uploadSuccess: Driver<Void>?
    public var alert: Driver<Entity.DefaultAlertContentVO>?
    
    public var profileRenderObject: Driver<WorkerProfileRenderObject>?
    private let rederingState: BehaviorRelay<WorkerProfileRenderObject> = .init(value: .createRO(isMyProfile: true, vo: .mock))
    
    // Editing & State
    var willSubmitImage: UIImage?
    var editingState: WorkerProfileStateObject = .default
    var currentState: WorkerProfileStateObject = .default
    
    let disposbag: DisposeBag = .init()
    
    public init() {
        
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
        
        // Edit Input
        editingImage
            .subscribe { [weak self] image in
                self?.willSubmitImage = image
            }
            .disposed(by: disposbag)
        
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
        
        uploadSuccess = editingRequestResult
            .compactMap { $0.value }
            .asDriver(onErrorRecover: { _ in fatalError() })
        
        alert = editingRequestResult
            .compactMap { $0.error }
            .map { error in
                DefaultAlertContentVO(
                    title: "공고 수정 오류",
                    message: error.message
                )
            }
            .asDriver(onErrorJustReturn: .default)
        
        profileRenderObject = rederingState.asDriver(onErrorRecover: { _ in fatalError() })
    }
    
    private func fetchProfileVO() -> Single<Result<WorkerProfileVO, Error>> {
        return .just(.success(.mock))
    }
    
    public func requestUpload(editObject: WorkerProfileStateObject) -> Single<Result<Void, UserInfoError>> {
        
        var submitObject: WorkerProfileStateObject = .init()
        
        submitObject.experienceYear = (currentState.experienceYear != editObject.experienceYear) ? editObject.experienceYear : nil
        
        submitObject.introduce = (currentState.introduce != editObject.introduce) ? editObject.introduce : nil
        
        submitObject.isJobFinding = (currentState.isJobFinding != editObject.isJobFinding) ? editObject.isJobFinding : nil
        
        submitObject.lotNumberAddress = (currentState.lotNumberAddress != editObject.lotNumberAddress) ? editObject.lotNumberAddress : nil
        
        submitObject.roadNameAddress = (currentState.roadNameAddress != editObject.roadNameAddress) ? editObject.roadNameAddress : nil
        
        submitObject.speciality = (currentState.speciality != editObject.speciality) ? editObject.speciality : nil
        
        return .just(.success(()))
    }
}

