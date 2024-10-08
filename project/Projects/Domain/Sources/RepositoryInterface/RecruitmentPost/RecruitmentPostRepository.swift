//
//  RecruitmentPostRepository.swift
//  RepositoryInterface
//
//  Created by choijunios on 8/8/24.
//

import Foundation


import RxSwift

public protocol RecruitmentPostRepository: RepositoryBase {
    
    // MARK: Center - post crud
    /// 공고를 등록합니다.
    func registerPost(bundle: RegisterRecruitmentPostBundle) -> Single<Result<Void, DomainError>>

    /// 센터측에서 등록한 공고의 상세내역을 확인합니다.
    func getPostDetailForCenter(id: String) -> Single<Result<RegisterRecruitmentPostBundle, DomainError>>

    /// 센터가 등록한 공고의 상세정보를 수정합니다.
    func editPostDetail(id: String, bundle: RegisterRecruitmentPostBundle) -> Single<Result<Void, DomainError>>

    // MARK: Center - check posts
    /// 현재 진행중인 공고를 획득합니다.
    func getOngoingPosts() -> Single<Result<[RecruitmentPostInfoForCenterVO], DomainError>>

    /// 닫힌 공고를 획득합니다.
    func getClosedPosts() -> Single<Result<[RecruitmentPostInfoForCenterVO], DomainError>>

    /// 특정 공고의 지원자 수를 확인합니다.
    func getPostApplicantCount(id: String) -> Single<Result<Int, DomainError>>

    /// 특정 공고의 지원자 리스트를 조회합니다. 요약된 공고정보가 포함되어 있습니다.
    func getPostApplicantScreenData(id: String) -> Single<Result<PostApplicantScreenVO, DomainError>>

    /// 공고를 종료합니다.
    func closePost(id: String) -> Single<Result<Void, DomainError>>

    /// 공고를 삭제합니다.
    func removePost(id: String) -> Single<Result<Void, DomainError>>

    // MARK: Worker
    /// 요양보호사 앱내 공고의 상세정보를 조회합니다.
    func getNativePostDetailForWorker(id: String) -> Single<Result<RecruitmentPostForWorkerBundle, DomainError>>

    /// 요양보호사 워크넷 공고의 상세정보를 조회합니다.
    func getWorknetPostDetailForWorker(id: String) -> Single<Result<WorknetRecruitmentPostDetailVO, DomainError>>

    // MARK: Native post

    /// 요양보호사가 확인하는 케어밋 자체 공고정보를 가져옵니다.
    func getNativePostListForWorker(nextPageId: String?, requestCnt: Int) -> Single<Result<RecruitmentPostListForWorkerVO, DomainError>>

    /// 요양보호사가 즐겨찾는 케어밋 자체 공고정보를 가져옵니다.
    func getNativeFavoritePostListForWorker() -> Single<Result<[RecruitmentPostForWorkerRepresentable], DomainError>>

    /// 요양보호사가 즐겨찾는 워크넷 공고정보를 가져옵니다.
    func getWorknetFavoritePostListForWorker() -> Single<Result<[RecruitmentPostForWorkerRepresentable], DomainError>>

    /// 요양보호사가 확인하는 케어밋 자체 공고정보를 가져옵니다.
    func getAppliedPostListForWorker(nextPageId: String?, requestCnt: Int) -> Single<Result<RecruitmentPostListForWorkerVO, DomainError>>

    // MARK: Worknet Post

    /// 요양보호사가 확인하는 워크넷 공고정보를 가져옵니다.
    func getWorknetPostListForWorker(nextPageId: String?, requestCnt: Int) -> Single<Result<RecruitmentPostListForWorkerVO, DomainError>>

    /// 요양보호사가 인앱 공고에 지원합니다.
    func applyToPost(postId: String, method: ApplyType) -> Single<Result<Void, DomainError>>

    /// 요양보호사 즐겨찾기 공고 추가
    func addFavoritePost(postId: String, type: PostOriginType) -> Single<Result<Void, DomainError>>

    /// 요양보호사 즐겨찾기 공고 삭제
    func removeFavoritePost(postId: String) -> Single<Result<Void, DomainError>>
}
