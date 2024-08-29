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
import UseCaseInterface
import Entity


public class RecruitmentManagementCoordinator: RecruitmentManagementCoordinatable {
    
    public struct Dependency {
        let parent: CenterMainCoordinatable
        let injector: Injector
        let navigationController: UINavigationController
        
        init(parent: CenterMainCoordinatable, injector: Injector, navigationController: UINavigationController) {
            self.parent = parent
            self.injector = injector
            self.navigationController = navigationController
        }
    }
    
    public var childCoordinators: [any PresentationCore.Coordinator] = []
    
    public weak var viewControllerRef: UIViewController?
    
    public weak var parent: CenterMainCoordinatable?
    let injector: Injector
    public var navigationController: UINavigationController
    
    public init(
        dependency: Dependency
    ) {
        self.parent = dependency.parent
        self.injector = dependency.injector
        self.navigationController = dependency.navigationController
    }
    
    public func start() {
        let coordinator = CenterRecruitmentPostBoardScreenCoordinator(
            dependency: .init(
                navigationController: navigationController,
                recruitmentPostUseCase: injector.resolve(RecruitmentPostUseCase.self)
            )
        )
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
            dependency: .init(
                postId: postId,
                navigationController: navigationController,
                recruitmentPostUseCase: injector.resolve(RecruitmentPostUseCase.self),
                workerProfileUseCase: injector.resolve(WorkerProfileUseCase.self)
            )
        )
        addChildCoordinator(coordinator)
        coordinator.parent = self
        coordinator.start()
    }
    
    func showPostDetailScreenForCenter(postId: String, postState: PostState) {
        
        let coordinator = PostDetailForCenterCoordinator(
            dependency: .init(
                postId: postId,
                postState: postState,
                navigationController: navigationController,
                recruitmentPostUseCase: injector.resolve(RecruitmentPostUseCase.self)
            )
        )
        addChildCoordinator(coordinator)
        coordinator.parent = self
        coordinator.start()
    }
    
    func showEditScreen(postId: String) {
        
        let vm = EditPostVM(
            id: postId,
            recruitmentPostUseCase: injector.resolve(RecruitmentPostUseCase.self)
        )
        let coordinator = EditPostCoordinator(
            dependency: .init(
                navigationController: navigationController,
                viewModel: vm
            )
        )
        vm.editPostCoordinator = coordinator
        addChildCoordinator(coordinator)
        coordinator.parent = self
        coordinator.start()
    }
    
    func showRegisterPostScrean() {
        
        let coordinator = RegisterRecruitmentPostCoordinator(
            dependency: .init(
                navigationController: navigationController,
                recruitmentPostUseCase: injector.resolve(RecruitmentPostUseCase.self)
            )
        )
        addChildCoordinator(coordinator)
        coordinator.parent = self
        coordinator.start()
    }
}
