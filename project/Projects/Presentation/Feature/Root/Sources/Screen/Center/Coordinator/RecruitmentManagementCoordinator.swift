//
//  RecruitmentManagementCoordinator.swift
//  RootFeature
//
//  Created by choijunios on 7/25/24.
//

import UIKit
import CenterFeature
import PresentationCore
import UseCaseInterface
import Entity


public class RecruitmentManagementCoordinator: RecruitmentManagementCoordinatable {
    
    public struct Dependency {
        weak var parent: CenterMainCoordinatable?
        let navigationController: UINavigationController
        let workerProfileUseCase: WorkerProfileUseCase
        
        public init(parent: CenterMainCoordinatable? = nil, navigationController: UINavigationController, workerProfileUseCase: WorkerProfileUseCase) {
            self.parent = parent
            self.navigationController = navigationController
            self.workerProfileUseCase = workerProfileUseCase
        }
    }
    
    public var childCoordinators: [any PresentationCore.Coordinator] = []
    
    public weak var viewControllerRef: UIViewController?
    
    public var navigationController: UINavigationController
    
    public weak var parent: CenterMainCoordinatable?
    
    let workerProfileUseCase: WorkerProfileUseCase
    
    public init(
        dependency: Dependency
    ) {
        self.parent = dependency.parent
        self.navigationController = dependency.navigationController
        self.workerProfileUseCase = dependency.workerProfileUseCase
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
}

public extension RecruitmentManagementCoordinator {

    func showCheckingApplicantScreen(_ centerEmployCardVO: CenterEmployCardVO) {
        let coordinator = CheckApplicantCoordinator(
            dependency: .init(
                navigationController: navigationController,
                centerEmployCardVO: centerEmployCardVO,
                workerProfileUseCase: workerProfileUseCase
            )
        )
        addChildCoordinator(coordinator)
        coordinator.parent = self
        coordinator.start()
    }
}
