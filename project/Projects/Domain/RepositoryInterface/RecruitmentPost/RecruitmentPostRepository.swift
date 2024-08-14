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
    func registerPost(bundle: RegisterRecruitmentPostBundle) -> Single<Void>
    
    func getPostDetailForCenter(id: String) -> Single<RegisterRecruitmentPostBundle>
    
    func editPostDetail(id: String, bundle: RegisterRecruitmentPostBundle) -> Single<Void>
}
