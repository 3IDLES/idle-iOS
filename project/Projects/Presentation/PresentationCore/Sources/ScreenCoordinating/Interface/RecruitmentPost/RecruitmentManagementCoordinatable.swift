//
//  RecruitmentManagementCoordinatable.swift
//  PresentationCore
//
//  Created by choijunios on 8/13/24.
//

import Entity

public protocol RecruitmentManagementCoordinatable: ParentCoordinator {
    
    func showCheckingApplicantScreen(postId: String, _ centerEmployCardVO: CenterEmployCardVO)
    func showPostDetailScreenForCenter(postId: String, applicantCount: Int?)
    func showEditScreen(postId: String)
}
