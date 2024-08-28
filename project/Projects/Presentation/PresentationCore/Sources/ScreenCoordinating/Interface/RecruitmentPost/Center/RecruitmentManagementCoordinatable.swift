//
//  RecruitmentManagementCoordinatable.swift
//  PresentationCore
//
//  Created by choijunios on 8/13/24.
//

import Entity

public protocol RecruitmentManagementCoordinatable: ParentCoordinator {
    
    func showCheckingApplicantScreen(postId: String)
    func showPostDetailScreenForCenter(postId: String)
    func showEditScreen(postId: String)
}
