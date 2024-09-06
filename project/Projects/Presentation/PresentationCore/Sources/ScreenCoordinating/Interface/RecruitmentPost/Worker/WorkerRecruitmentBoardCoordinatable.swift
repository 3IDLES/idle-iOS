//
//  WorkerRecruitmentBoardCoordinatable.swift
//  PresentationCore
//
//  Created by choijunios on 8/15/24.
//

import Foundation
import Entity

public protocol WorkerRecruitmentBoardCoordinatable: ParentCoordinator {
    /// 요양보호사가 볼 수 있는 공고 상세정보를 표시합니다.
    func showPostDetail(postType: RecruitmentPostType, postId: String)
    
    /// 센터 프로필을 표시합니다.
    func showCenterProfile(centerId: String)
}
