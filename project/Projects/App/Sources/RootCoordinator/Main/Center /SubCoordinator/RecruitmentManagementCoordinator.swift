//
//  RecruitmentManagementCoordinator.swift
//  Idle-iOS
//
//  Created by choijunios on 7/25/24.
//

import UIKit
import RootFeature
import CenterFeature
import PresentationCore
import Domain
import Core


public class RecruitmentManagementCoordinator: RecruitmentManagementCoordinatable {
    
    public var childCoordinators: [any PresentationCore.Coordinator] = []
    
    public weak var viewControllerRef: UIViewController?
    
    public weak var parent: ParentCoordinator?
    
    public var navigationController: UINavigationController
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() {
        let coordinator = CenterRecruitmentPostBoardScreenCoordinator(navigationController: navigationController)
        addChildCoordinator(coordinator)
        coordinator.parent = self
        coordinator.start()
    }
    
    public func coordinatorDidFinish() {
        popViewController()
        parent?.removeChildCoordinator(self)
    }
}

public extension RecruitmentManagementCoordinator {

    func showCheckingApplicantScreen(postId: String) {
        let coordinator = CheckApplicantCoordinator(
            postId: postId,
            navigationController: navigationController
        )
        addChildCoordinator(coordinator)
        coordinator.start()
    }
    
    func showPostDetailScreenForCenter(postId: String, postState: PostState) {
        
        let coordinator = PostDetailForCenterCoordinator(
            postId: postId,
            postState: postState,
            navigationController: navigationController
        )
        addChildCoordinator(coordinator)
        coordinator.start()
    }
    
    func showEditScreen(postId: String) {
        
        let vm = EditPostVM(id: postId)
        let coordinator = EditPostCoordinator(
            viewModel: vm,
            navigationController: navigationController
        )
        vm.editPostCoordinator = coordinator
        addChildCoordinator(coordinator)
        coordinator.start()
    }
    
    func showRegisterPostScrean() {
        
        let coordinator = RegisterRecruitmentPostCoordinator(navigationController: navigationController)
        addChildCoordinator(coordinator)
        coordinator.start()
    }
}
