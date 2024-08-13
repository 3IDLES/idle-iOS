//
//  RegisterRecruitmentPostCoordinator.swift
//  Idle-iOS
//
//  Created by choijunios on 8/5/24.
//

import UIKit
import DSKit
import PresentationCore
import CenterFeature
import UseCaseInterface


class RegisterRecruitmentPostCoordinator: RegisterRecruitmentPostCoordinatable {
    
    struct Dependency {
        let navigationController: UINavigationController
        let injector: Injector
    }
    
    var childCoordinators: [Coordinator] = []
    
    var parent: ParentCoordinator?
    
    var navigationController: UINavigationController
    let injector: Injector
    
    var viewModel: RegisterRecruitmentPostViewModelable!
    
    init(dependency: Dependency) {
        self.navigationController = dependency.navigationController
        self.injector = dependency.injector
    }
    
    func start() {
        self.viewModel = RegisterRecruitmentPostVM(
            recruitmentPostUseCase: injector.resolve(RecruitmentPostUseCase.self)
        )
        
        let coordinator = RegisterRecruitmentCoordinator(
            viewModel: viewModel,
            navigationController: navigationController
        )
        coordinator.parent = self
        addChildCoordinator(coordinator)
        coordinator.start()
    }
}

extension RegisterRecruitmentPostCoordinator {
    
    func showOverViewScreen() {
        let coordinator = PostOverviewCoordinator(
            viewModel: viewModel,
            navigationController: navigationController
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
        parent?.removeChildCoordinator(self)
    }
}
