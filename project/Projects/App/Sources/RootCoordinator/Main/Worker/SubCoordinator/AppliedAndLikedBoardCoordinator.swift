//
//  AppliedAndLikedBoardCoordinator.swift
//  RootFeature
//
//  Created by choijunios on 8/19/24.
//

import UIKit
import WorkerFeature
import Entity
import BaseFeature
import CenterFeature
import PresentationCore
import UseCaseInterface

class AppliedAndLikedBoardCoordinator: WorkerRecruitmentBoardCoordinatable {
    
    struct Dependency {
        let parent: WorkerMainCoordinator
        let injector: Injector
        let navigationController: UINavigationController
        
        init(parent: WorkerMainCoordinator, injector: Injector, navigationController: UINavigationController) {
            self.parent = parent
            self.injector = injector
            self.navigationController = navigationController
        }
    }
    
    var childCoordinators: [any PresentationCore.Coordinator] = []
    
    weak var viewControllerRef: UIViewController?
    
    var navigationController: UINavigationController
    weak var parent: ParentCoordinator?
    let injector: Injector
    
    public init(depedency: Dependency) {
        self.parent = depedency.parent
        self.navigationController = depedency.navigationController
        self.injector = depedency.injector
    }
    
    public func start() {
        let vc = StarredAndAppliedVC()
        let appliedVM = AppliedPostBoardVM(
            coordinator: self,
            recruitmentPostUseCase: injector.resolve(RecruitmentPostUseCase.self)
        )
        let starredVM = StarredPostBoardVM(
            coordinator: self,
            recruitmentPostUseCase: injector.resolve(RecruitmentPostUseCase.self)
        )
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
    public func showPostDetail(postType: RecruitmentPostType, postId: String) {
        let coodinator = PostDetailForWorkerCoodinator(
            dependency: .init(
                postType: postType,
                postId: postId,
                parent: self,
                navigationController: navigationController,
                recruitmentPostUseCase: injector.resolve(RecruitmentPostUseCase.self),
                workerProfileUseCase: injector.resolve(WorkerProfileUseCase.self),
                centerProfileUseCase: injector.resolve(CenterProfileUseCase.self)
            )
        )
        addChildCoordinator(coodinator)
        coodinator.start()
    }
    public func showCenterProfile(centerId: String) {
        let coordinator = CenterProfileCoordinator(
            dependency: .init(
                mode: .otherProfile(id: centerId),
                profileUseCase: injector.resolve(CenterProfileUseCase.self),
                navigationController: navigationController
            )
        )
        addChildCoordinator(coordinator)
        coordinator.parent = self
        coordinator.start()
    }
    
    func showWorkerProfile() { }
}
