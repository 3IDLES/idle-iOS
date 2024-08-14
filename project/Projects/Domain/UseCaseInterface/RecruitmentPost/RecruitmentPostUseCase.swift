//
//  RecruitmentPostUseCase.swift
//  RecruitmentPostUseCase
//
//  Created by choijunios on 8/9/24.
//

import Foundation
import Entity
import RxSwift

public protocol RecruitmentPostUseCase: UseCaseBase {
    
    /// 센터측이 공고를 등록하는 액션입니다.
    func registerRecruitmentPost(inputs: RegisterRecruitmentPostBundle) -> Single<Result<Void, RecruitmentPostError>>
    
    /// 센터측이 공고를 조회하는 액션입니다.
    func getPostDetailForCenter(id: String) -> Single<Result<RegisterRecruitmentPostBundle, RecruitmentPostError>>
}
