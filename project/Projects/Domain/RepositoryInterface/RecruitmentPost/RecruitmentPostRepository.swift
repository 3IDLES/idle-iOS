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
    
    /// 요양보호사 메인화면에 표시될 유효한 공고를 조회합니다.
    func getPostListForWorker(nextPageId: String?, requestCnt: Int) -> Single<RecruitmentPostListForWorkerVO>
}
