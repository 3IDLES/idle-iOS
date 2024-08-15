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
 
    // MARK: Center
    
    /// 센터측이 공고를 등록하는 액션입니다.
    func registerRecruitmentPost(inputs: RegisterRecruitmentPostBundle) -> Single<Result<Void, RecruitmentPostError>>
    
    /// 센터측이 공고를 수정하는 액션입니다.
    func editRecruitmentPost(id: String, inputs: RegisterRecruitmentPostBundle) -> Single<Result<Void, RecruitmentPostError>>
    
    /// 센터측이 공고를 조회하는 액션입니다.
    func getPostDetailForCenter(id: String) -> Single<Result<RegisterRecruitmentPostBundle, RecruitmentPostError>>
    
    
    // MARK: Worker
    
    /// 요양보호사가 공고상세를 확인하는 경우에 호출합니다.
    /// - 반환값
    ///     - 공고상세정보(센터와 달리 고객 이름 배제)
    ///     - 근무지 위치(위경도)
    ///     - 센터정보(센터 id, 이름, 도로명 주소)
    func getPostDetailForWorker(id: String) -> Single<Result<RecruitmentPostForWorkerBundle, RecruitmentPostError>>
}
