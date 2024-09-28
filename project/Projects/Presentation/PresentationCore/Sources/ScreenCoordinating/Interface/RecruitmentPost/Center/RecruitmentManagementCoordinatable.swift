//
//  RecruitmentManagementCoordinatable.swift
//  PresentationCore
//
//  Created by choijunios on 8/13/24.
//

import Domain


public protocol RecruitmentManagementCoordinatable: ParentCoordinator {
    
    func showCheckingApplicantScreen(postId: String)
    func showPostDetailScreenForCenter(postId: String, postState: PostState)
    func showEditScreen(postId: String)
    func showRegisterPostScrean()
}
