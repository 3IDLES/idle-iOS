//
//  RecruitmentPostRepository.swift
//  RepositoryInterface
//
//  Created by choijunios on 8/8/24.
//

import Foundation
import RxSwift
import Entity

public protocol RecruitmentPostRepository: RepositoryBase {
    
    // MARK: Center - post crud
    /// 공고를 등록합니다.
    func registerPost(bundle: RegisterRecruitmentPostBundle) -> Single<Void>
    
    /// 센터측에서 등록한 공고의 상세내역을 확인합니다.
    func getPostDetailForCenter(id: String) -> Single<RegisterRecruitmentPostBundle>
    
    /// 센터가 등록한 공고의 상세정보를 수정합니다.
    func editPostDetail(id: String, bundle: RegisterRecruitmentPostBundle) -> Single<Void>
    
    // MARK: Center - check posts
    /// 현재 진행중인 공고를 획득합니다.
    func getOngoingPosts() -> Single<[RecruitmentPostInfoForCenterVO]>
    
    /// 현재 진행중인 공고를 획득합니다.
    func getClosedPosts() -> Single<[RecruitmentPostInfoForCenterVO]>
    
    /// 특정 공고의 지원자 수를 확인합니다.
    func getPostApplicantCount(id: String) -> Single<Int>
    
    /// 특정 공고의 지원자 리스트를 조회합니다. 요약된 공고정보가 포함되어 있습니다.
    func getPostApplicantScreenData(id: String) -> Single<PostApplicantScreenVO>
    
    /// 공고를 종료합니다.
    func closePost(id: String) -> Single<Void>
    
    /// 공고를 삭제합니다.
    func removePost(id: String) -> Single<Void>
    
    // MARK: Worker
    /// 요양보호사 공고의 상세정보를 조회합니다.
    func getPostDetailForWorker(id: String) -> Single<RecruitmentPostForWorkerBundle>
    
    /// 요양보호사가 확인하는 케어밋 자체 공고정보를 가져옵니다.
    func getNativePostListForWorker(nextPageId: String?, requestCnt: Int) -> Single<RecruitmentPostListForWorkerVO>
    
    /// 요양보호사가 확인하는 케어밋 자체 공고정보를 가져옵니다.
    func getFavoritePostListForWorker(nextPageId: String?, requestCnt: Int) -> Single<RecruitmentPostListForWorkerVO>
    
    /// 요양보호사가 확인하는 케어밋 자체 공고정보를 가져옵니다.
    func getAppliedPostListForWorker(nextPageId: String?, requestCnt: Int) -> Single<RecruitmentPostListForWorkerVO>
    
    /// 요양보호사가 인앱 공고에 지원합니다.
    func applyToPost(postId: String, method: ApplyType) -> Single<Void>
    
    /// 요양보호사 즐겨찾기 공고 추가
    func addFavoritePost(postId: String, type: RecruitmentPostType) -> Single<Void>
    
    /// 요양보호사 즐겨찾기 공고 삭제
    func removeFavoritePost(postId: String) -> Single<Void>
}
