//
//  RegisterRecruitmentPostCoordinator.swift
//  CenterFeature
//
//  Created by choijunios on 8/14/24.
//

import UIKit
import PresentationCore
import Domain
import BaseFeature
import Core


public class RegisterRecruitmentPostCoordinator: RegisterRecruitmentPostCoordinatable {
    
    @Injected var logger: PostRegisterLogger
    
    public var childCoordinators: [Coordinator] = []
    
    public var parent: ParentCoordinator?
    
    public var navigationController: UINavigationController
    
    var viewControllerRef: UIViewController?
    var registerRecruitmentPostVM: RegisterRecruitmentPostViewModelable!
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.registerRecruitmentPostVM = RegisterRecruitmentPostVM(coordinator: self)
    }
    
    public func start() {
        let vc = RegisterRecruitmentPostVC()
        vc.bind(viewModel: registerRecruitmentPostVM)
        
        let coordinator = CoordinatorWrapper(
            nav: navigationController,
            vc: vc
        )
        addChildCoordinator(coordinator)
        coordinator.start()
        
        // MARK: 로깅
        logger.startPostRegister()
    }
}

public extension RegisterRecruitmentPostCoordinator {
    
    func showEditPostScreen() {
        let coordinator = EditPostCoordinator(
            viewModel: registerRecruitmentPostVM,
            navigationController: navigationController
        )
        addChildCoordinator(coordinator)
        coordinator.start()
    }
    
    func showOverViewScreen() {
        let coordinator = PostOverviewCoordinator(
            viewModel: registerRecruitmentPostVM,
            navigationController: navigationController
        )
        addChildCoordinator(coordinator)
        coordinator.start()
    }
    
    func showRegisterCompleteScreen() {
        let coordinator = RegisterCompleteCoordinator(
            navigationController: navigationController
        )
        addChildCoordinator(coordinator)
        coordinator.start()
        
        // MARK: 로깅
        logger.logPostRegisterDuration()
    }
    
    func registerFinished() {
        clearChildren()
        popViewController(animated: false)
        parent?.removeChildCoordinator(self)
    }
}
