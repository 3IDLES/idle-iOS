//
//  asd.swift
//  RootFeature
//
//  Created by choijunios on 8/14/24.
//

import UIKit
import PresentationCore
import UseCaseInterface
import Entity
import CenterFeature
import WorkerFeature
import BaseFeature


public class RegisterRecruitmentPostCoordinator: RegisterRecruitmentPostCoordinatable {
    
    public struct Dependency {
        let navigationController: UINavigationController
        let recruitmentPostUseCase: RecruitmentPostUseCase
        
        public init(navigationController: UINavigationController, recruitmentPostUseCase: RecruitmentPostUseCase) {
            self.navigationController = navigationController
            self.recruitmentPostUseCase = recruitmentPostUseCase
        }
    }
    
    public var childCoordinators: [Coordinator] = []
    
    public var parent: ParentCoordinator?
    
    public var navigationController: UINavigationController
    
    var viewControllerRef: UIViewController?
    var registerRecruitmentPostVM: RegisterRecruitmentPostViewModelable!
    
    public init(dependency: Dependency) {
        self.navigationController = dependency.navigationController
        self.registerRecruitmentPostVM = RegisterRecruitmentPostVM(
            registerRecruitmentPostCoordinator: self,
            recruitmentPostUseCase: dependency.recruitmentPostUseCase
        )
    }
    
    public func start() {
        let vc = RegisterRecruitmentPostVC()
        
        vc.bind(viewModel: registerRecruitmentPostVM)
        viewControllerRef = vc
        navigationController.pushViewController(vc, animated: true)
    }
}

public extension RegisterRecruitmentPostCoordinator {
    
    func showEditPostScreen() {
        let coordinator = EditPostCoordinator(
            dependency: .init(
                navigationController: navigationController,
                viewModel: registerRecruitmentPostVM
            )
        )
        coordinator.parent = self
        addChildCoordinator(coordinator)
        coordinator.start()
    }
    
    func showOverViewScreen() {
        let coordinator = PostOverviewCoordinator(
            dependency: .init(
                navigationController: navigationController,
                viewModel: registerRecruitmentPostVM
            )
        )
        coordinator.parent = self
        addChildCoordinator(coordinator)
        coordinator.start()
    }
    
    func showRegisterCompleteScreen() {
        let coordinator = RegisterCompleteCoordinator(
            navigationController: navigationController
        )
        coordinator.parent = self
        addChildCoordinator(coordinator)
        coordinator.start()
    }
    
    func registerFinished() {
        clearChildren()
        popViewController(animated: false)
        parent?.removeChildCoordinator(self)
    }
}
