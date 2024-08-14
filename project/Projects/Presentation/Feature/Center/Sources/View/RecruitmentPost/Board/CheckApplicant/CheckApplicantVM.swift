//
//  CheckApplicantVM.swift
//  CenterFeature
//
//  Created by choijunios on 8/13/24.
//

import Foundation
import RxSwift
import RxCocoa
import Entity
import DSKit
import PresentationCore

public protocol CheckApplicantViewModelable {
    // Input
    var requestpostApplicantVO: PublishRelay<Void> { get }
    var exitButtonClicked: PublishRelay<Void> { get }
    
    // Output
    var postApplicantVO: Driver<[PostApplicantVO]>? { get }
    var postCardVO: CenterEmployCardVO { get }
    var alert: Driver<DefaultAlertContentVO>? { get }
    
    func createApplicantCardVM(vo: PostApplicantVO) -> ApplicantCardVM
}

public class CheckApplicantVM: CheckApplicantViewModelable {
    
    weak var coorindator: CheckApplicantCoordinatable?
    
    public var exitButtonClicked: PublishRelay<Void> = .init()
    public var requestpostApplicantVO: PublishRelay<Void> = .init()
    public var postCardVO: CenterEmployCardVO
    
    public var postApplicantVO: Driver<[PostApplicantVO]>?
    public var alert: RxCocoa.Driver<Entity.DefaultAlertContentVO>?
    
    let disposeBag = DisposeBag()
    
    public init(postCardVO: CenterEmployCardVO, coorindator: CheckApplicantCoordinatable?) {
        self.postCardVO = postCardVO
        self.coorindator = coorindator
        
        exitButtonClicked
            .subscribe(onNext: { [weak self] _ in
                
                self?.coorindator?.taskFinished()
            })
            .disposed(by: disposeBag)
        
        // Input
        let requestPostApplicantVOResult = requestpostApplicantVO
            .flatMap { [unowned self] _ in
                publishPostApplicantVOMocks()
            }
            .share()
            
        let requestPostApplicantSuccess = requestPostApplicantVOResult.compactMap { $0.value }
        let requestPostApplicantFailure = requestPostApplicantVOResult.compactMap { $0.error }
        
        // Output
        postApplicantVO = requestPostApplicantSuccess.asDriver(onErrorJustReturn: [])
        
        alert = requestPostApplicantFailure
            .map { error in
                
                DefaultAlertContentVO(
                    title: "시스템 오류",
                    message: error.message
                )
            }
            .asDriver(onErrorJustReturn: .default)
    }
    
    public func createApplicantCardVM(vo: PostApplicantVO) -> ApplicantCardVM {
        .init(vo: vo, coordinator: coorindator)
    }
    
    func publishPostApplicantVOMocks() -> Single<Result<[PostApplicantVO], RecruitmentPostError>> {
        
        .just(.success((0...10).map { _ in PostApplicantVO.mock }))
    }
}


// MARK: ApplicantCardVM
public class ApplicantCardVM: ApplicantCardViewModelable {
    
    // Init
    let id: String
    weak var coordinator: CheckApplicantCoordinatable?
    
    public var showProfileButtonClicked: PublishRelay<Void> = .init()
    public var employButtonClicked: PublishRelay<Void> = .init()
    public var staredThisWorker: PublishRelay<Bool> = .init()
    
    public var renderObject: Driver<ApplicantCardRO>?
    
    let disposeBag = DisposeBag()
    
    public init(vo: PostApplicantVO, coordinator: CheckApplicantCoordinatable?) {
        self.id = vo.workerId
        self.coordinator = coordinator
        
        // MARK: RenderObject
        let publishRelay: BehaviorRelay<ApplicantCardRO> = .init(value: .mock)
        renderObject = publishRelay.asDriver(onErrorJustReturn: .mock)
        
        publishRelay.accept(ApplicantCardRO.create(vo: vo))
        
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
