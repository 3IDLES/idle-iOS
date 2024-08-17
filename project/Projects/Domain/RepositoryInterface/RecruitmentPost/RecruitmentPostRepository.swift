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
    
    // MARK: Center
    /// 공고를 등록합니다.
    func registerPost(bundle: RegisterRecruitmentPostBundle) -> Single<Void>
    
    /// 센터측에서 등록한 공고의 상세내역을 확인합니다.
    func getPostDetailForCenter(id: String) -> Single<RegisterRecruitmentPostBundle>
    
    /// 센터가 등록한 공고의 상세정보를 수정합니다.
    func editPostDetail(id: String, bundle: RegisterRecruitmentPostBundle) -> Single<Void>
    
    // MARK: Worker
    /// 요양보호사 공고의 상세정보를 조회합니다.
    func getPostDetailForWorker(id: String) -> Single<RecruitmentPostForWorkerBundle>
    
    /// 요샹보호사가 확인하는 케어밋 자체 공고정보를 가져옵니다.
    func getNativePostListForWorker(nextPageId: String?, requestCnt: Int) -> Single<RecruitmentPostListForWorkerVO>
}
