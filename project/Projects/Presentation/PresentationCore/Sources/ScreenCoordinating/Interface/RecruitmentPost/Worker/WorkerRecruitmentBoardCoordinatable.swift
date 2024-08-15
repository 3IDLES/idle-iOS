//
//  WorkerRecruitmentBoardCoordinatable.swift
//  PresentationCore
//
//  Created by choijunios on 8/15/24.
//

import Foundation

public protocol WorkerRecruitmentBoardCoordinatable: ParentCoordinator {
    /// 요양보호사가 볼 수 있는 공고 상세정보를 표시합니다.
    func showPostDetail(postId: String)
    
    /// 센터 프로필을 표시합니다.
    func showCenterProfile(centerId: String)
}
