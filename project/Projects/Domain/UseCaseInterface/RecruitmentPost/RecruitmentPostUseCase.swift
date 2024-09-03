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
    func registerRecruitmentPost(inputs: RegisterRecruitmentPostBundle) -> Single<Result<Void, DomainError>>
    
    /// 센터측이 공고를 수정하는 액션입니다.
    func editRecruitmentPost(id: String, inputs: RegisterRecruitmentPostBundle) -> Single<Result<Void, DomainError>>
    
    /// 센터측이 공고상세 정보를 조회하는 액션입니다.
    func getPostDetailForCenter(id: String) -> Single<Result<RegisterRecruitmentPostBundle, DomainError>>
    
    /// 진행중인 공고정보를 가져옵니다.
    func getOngoingPosts() -> Single<Result<[RecruitmentPostInfoForCenterVO], DomainError>>
    
    /// 지난 공고정보를 가져옵니다.
    func getClosedPosts() -> Single<Result<[RecruitmentPostInfoForCenterVO], DomainError>>
    
    /// 공고에 지원한 지원자 수를 가져옵니다.
    func getPostApplicantCount(id: String) -> Single<Result<Int, DomainError>>
    
    /// 지원자 확인 화면에 사용될 정보를 가져옵니다.
    func getPostApplicantScreenData(id: String) -> Single<Result<PostApplicantScreenVO,DomainError>>
    
    /// 공고를 종료합니다.
    func closePost(id: String) -> Single<Result<Void, DomainError>>
    
    /// 공고를 삭제합니다.
    func removePost(id: String) -> Single<Result<Void, DomainError>>
    
    // MARK: Worker
    
    /// 요양보호사가 공고상세를 확인하는 경우에 호출합니다.
    /// - 반환값
    ///     - 공고상세정보(센터와 달리 고객 이름 배제)
    ///     - 근무지 위치(위경도)
    ///     - 센터정보(센터 id, 이름, 도로명 주소)
    func getPostDetailForWorker(id: String) -> Single<Result<RecruitmentPostForWorkerBundle, DomainError>>
    
    /// 요양보호사가 메인화면에 사용할 공고리스트를 호출합니다.
    func getPostListForWorker(request: PostPagingRequestForWorker, postCount: Int) -> Single<Result<RecruitmentPostListForWorkerVO, DomainError>>
    
    /// 요양보호사가 즐겨찾기한 공고리스트를 호출합니다.
    func getFavoritePostListForWorker(request: PostPagingRequestForWorker, postCount: Int) -> Single<Result<RecruitmentPostListForWorkerVO, DomainError>>
    
    /// 요양보호사가 지원한 공고리스트를 호출합니다.
    func getAppliedPostListForWorker(request: PostPagingRequestForWorker, postCount: Int) -> Single<Result<RecruitmentPostListForWorkerVO, DomainError>>
    
    /// 요양보호사가 인앱공고에 지원합니다.
    func applyToPost(postId: String, method: ApplyType) -> Single<Result<Void, DomainError>>
}
