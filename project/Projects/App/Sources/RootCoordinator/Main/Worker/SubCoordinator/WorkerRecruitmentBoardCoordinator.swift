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
import UseCaseInterface

class WorkerRecruitmentBoardCoordinator: WorkerRecruitmentBoardCoordinatable {
    
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
    
    init(depedency: Dependency) {
        self.navigationController = depedency.navigationController
        self.parent = depedency.parent
        self.injector = depedency.injector
    }
    
    func start() {
        let vc = WorkerRecruitmentPostBoardVC()
        let vm = WorkerRecruitmentPostBoardVM(
            coordinator: self,
            recruitmentPostUseCase: injector.resolve(RecruitmentPostUseCase.self),
            workerProfileUseCase: injector.resolve(WorkerProfileUseCase.self)
        )
        vc.bind(viewModel: vm)
        viewControllerRef = vc
        navigationController.pushViewController(vc, animated: false)
    }
}

extension WorkerRecruitmentBoardCoordinator {
    public func showPostDetail(postId: String) {
        let coodinator = PostDetailForWorkerCoodinator(
            dependency: .init(
                postId: postId,
                parent: self,
                navigationController: navigationController,
                recruitmentPostUseCase: injector.resolve(RecruitmentPostUseCase.self)
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
}

