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
    
    func publishPostApplicantVOMocks() -> Single<Result<[PostApplicantVO], RecruitmentPostError>> {
        
        .just(.success((0...10).map { _ in PostApplicantVO.mock }))
    }
}
