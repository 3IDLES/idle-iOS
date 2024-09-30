//
//  AppliedAndLikedBoardCoordinator.swift
//  RootFeature
//
//  Created by choijunios on 8/19/24.
//

import UIKit
import WorkerFeature
import BaseFeature
import CenterFeature
import PresentationCore
import Domain
import Core

class AppliedAndLikedBoardCoordinator: WorkerRecruitmentBoardCoordinatable {
    
    var childCoordinators: [any PresentationCore.Coordinator] = []
    
    weak var viewControllerRef: UIViewController?
    
    var navigationController: UINavigationController
    weak var parent: ParentCoordinator?
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() {
        let vc = StarredAndAppliedVC()
        let appliedVM = AppliedPostBoardVM(coordinator: self)
        let starredVM = StarredPostBoardVM(coordinator: self)
        vc.bind(
            appliedPostVM: appliedVM,
            starredPostVM: starredVM
        )
        viewControllerRef = vc
        navigationController.pushViewController(vc, animated: false)
    }
    
    public func coordinatorDidFinish() {
        popViewController()
        parent?.removeChildCoordinator(self)
    }
}

extension AppliedAndLikedBoardCoordinator {
    public func showPostDetail(postInfo: RecruitmentPostInfo) {
        let coordinator = PostDetailForWorkerCoodinator(
            postInfo: postInfo,
            navigationController: navigationController
        )
        addChildCoordinator(coordinator)
        coordinator.parent = self
        coordinator.start()
    }
    public func showCenterProfile(centerId: String) {
        let coordinator = CenterProfileCoordinator(
            mode: .otherProfile(id: centerId),
            navigationController: navigationController
        )
        addChildCoordinator(coordinator)
        coordinator.parent = self
        coordinator.start()
    }
    
    func showWorkerProfile() { }
}
