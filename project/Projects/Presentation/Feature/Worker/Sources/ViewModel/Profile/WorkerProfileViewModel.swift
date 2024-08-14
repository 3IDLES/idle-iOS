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

/// 자신의 프로필을 확인하는 경우가 아닌 센터측에서 요양보호사를 보는 경우
public protocol OtherWorkerProfileViewModelable: WorkerProfileViewModelable {
    
    var phoneCallButtonClicked: PublishRelay<Void> { get }
}

public class WorkerProfileViewModel: OtherWorkerProfileViewModelable {
    
    public weak var coordinator: WorkerProfileCoordinator?
    
    let workerProfileUseCase: WorkerProfileUseCase
    
    // Init
    let workerId: String
    
    // Input(Rendering)
    public var viewWillAppear: PublishRelay<Void> = .init()
    public var exitButtonClicked: PublishRelay<Void> = .init()
    public var phoneCallButtonClicked: PublishRelay<Void> = .init()
    
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
    
    public init(
        coordinator: WorkerProfileCoordinator?,
        workerProfileUseCase: WorkerProfileUseCase,
        workerId: String
    ) {
        
        self.coordinator = coordinator
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
        
        exitButtonClicked
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.coordinatorDidFinish()
            })
            .disposed(by: disposbag)
        
        phoneCallButtonClicked
            .subscribe(onNext: { _ in
                
                // 안심번호 전화연결
                
            })
            .disposed(by: disposbag)
        
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

