//
//  WorkerRecruitmentBoardCoordinator.swift
//  Idle-iOS
//
//  Created by choijunios on 7/25/24.
//

import UIKit
import WorkerFeature
import BaseFeature
import CenterFeature
import PresentationCore
import Domain
import Core

class WorkerRecruitmentBoardCoordinator: WorkerRecruitmentBoardCoordinatable {
    
    var childCoordinators: [any PresentationCore.Coordinator] = []
    
    weak var viewControllerRef: UIViewController?
    
    var navigationController: UINavigationController
    weak var parent: ParentCoordinator?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = WorkerRecruitmentPostBoardVC()
        let vm = WorkerRecruitmentPostBoardVM(coordinator: self)
        vc.bind(viewModel: vm)
        viewControllerRef = vc
        navigationController.pushViewController(vc, animated: false)
    }
}

extension WorkerRecruitmentBoardCoordinator {
    public func showPostDetail(postInfo: RecruitmentPostInfo) {
        let coodinator = PostDetailForWorkerCoodinator(
            postInfo: postInfo,
            navigationController: navigationController
        )
        coodinator.parent = self
        addChildCoordinator(coodinator)
        coodinator.start()
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
    
    public func showWorkerProfile() {
        let coordinator = WorkerProfileCoordinator(
            profileMode: .myProfile,
            navigationController: navigationController
        )
        addChildCoordinator(coordinator)
        coordinator.parent = self
        coordinator.start()
    }
}

