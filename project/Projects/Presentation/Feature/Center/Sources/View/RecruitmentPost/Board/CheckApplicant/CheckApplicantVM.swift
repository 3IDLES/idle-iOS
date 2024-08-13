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

public class CheckApplicantVM: CheckApplicantViewModelable {
    
    public var requestpostApplicantVO: PublishRelay<Void> = .init()
    public var postCardVO: CenterEmployCardVO
    
    public var postApplicantVO: Driver<[PostApplicantVO]>?
    public var alert: RxCocoa.Driver<Entity.DefaultAlertContentVO>?
    
    public init(postCardVO: CenterEmployCardVO) {
        self.postCardVO = postCardVO
        
        let requestPostApplicantVOResult = requestpostApplicantVO
            .flatMap { [unowned self] _ in
                publishPostApplicantVOMocks()
            }
            .share()
            
        let requestPostApplicantSuccess = requestPostApplicantVOResult.compactMap { $0.value }
        let requestPostApplicantFailure = requestPostApplicantVOResult.compactMap { $0.error }
        
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
