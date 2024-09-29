//
//  CenterRecruitmentPostBoardScreenCoordinator.swift
//  CenterFeature
//
//  Created by choijunios on 8/25/24.
//

import UIKit
import PresentationCore
import Domain
import Core

public class CenterRecruitmentPostBoardScreenCoordinator: ChildCoordinator {
    
    public weak var viewControllerRef: UIViewController?
    public weak var parent: ParentCoordinator?
    
    var recruitmentManagementCoordinatable: RecruitmentManagementCoordinatable? {
        parent as? RecruitmentManagementCoordinatable
    }
    
    public let navigationController: UINavigationController
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    deinit {
        printIfDebug("\(String(describing: RegisterRecruitmentCoordinator.self))")
    }
    
    public func start() {
        let vc = CenterRecruitmentPostBoardVC()
        let vm = CenterRecruitmentPostBoardVM(coordinator: self)
        vc.bind(viewModel: vm)
        viewControllerRef = vc
        navigationController.pushViewController(vc, animated: false)
    }
    
    public func coordinatorDidFinish() {
        popViewController()
        parent?.removeChildCoordinator(self)
    }
    
    public func showCheckingApplicantScreen(postId: String) {
        recruitmentManagementCoordinatable?.showCheckingApplicantScreen(postId: postId)
    }
    
    public func showPostDetailScreenForCenter(postId: String, postState: PostState) {
        
        recruitmentManagementCoordinatable?.showPostDetailScreenForCenter(postId: postId, postState: postState)
    }
    
    public func showEditScreen(postId: String) {
        recruitmentManagementCoordinatable?.showEditScreen(postId: postId)
    }
    
    public func showRegisterPostScreen() {
        recruitmentManagementCoordinatable?.showRegisterPostScrean()
    }
}

