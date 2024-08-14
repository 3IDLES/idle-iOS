//
//  WorkerProfileViewModel.swift
//  WorkerFeature
//
//  Created by choijunios on 8/10/24.
//

import UIKit
import PresentationCore
import RxSwift
import RxCocoa
import DSKit
import Entity
import UseCaseInterface

public class WorkerProfileViewModel: WorkerProfileViewModelable {
    
    let workerProfileUseCase: WorkerProfileUseCase
    
    // Init
    let workerId: String
    
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
    
    public init(workerProfileUseCase: WorkerProfileUseCase, workerId: String) {
        
        self.workerProfileUseCase = workerProfileUseCase
        self.workerId = workerId
        
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
                WorkerProfileRenderObject.createRO(isMyProfile: false, vo: vo)
            })
            .bind(to: rederingState)
            .disposed(by: disposbag)
        
        profileRenderObject = rederingState.asDriver(onErrorRecover: { _ in fatalError() })
    }
    
    private func fetchProfileVO() -> Single<Result<WorkerProfileVO, UserInfoError>> {
        workerProfileUseCase
            .getProfile(mode: .otherProfile(id: self.workerId))
    }
}

