//
//  CheckApplicantCoordinator.swift
//  RootFeature
//
//  Created by choijunios on 8/13/24.
//

import UIKit
import PresentationCore
import UseCaseInterface
import CenterFeature
import WorkerFeature
import Entity
import BaseFeature

public class CheckApplicantCoordinator: CheckApplicantCoordinatable {
    
    public var childCoordinators: [any PresentationCore.Coordinator] = []
    
    public struct Dependency {
        let navigationController: UINavigationController
        let centerEmployCardVO: CenterEmployCardVO
        let workerProfileUseCase: WorkerProfileUseCase
        
        public init(navigationController: UINavigationController, centerEmployCardVO: CenterEmployCardVO, workerProfileUseCase: WorkerProfileUseCase) {
            self.navigationController = navigationController
            self.centerEmployCardVO = centerEmployCardVO
            self.workerProfileUseCase = workerProfileUseCase
        }
    }
    
    public weak var viewControllerRef: UIViewController?
    public weak var parent: ParentCoordinator?
    
    public let navigationController: UINavigationController
    let centerEmployCardVO: CenterEmployCardVO
    let workerProfileUseCase: WorkerProfileUseCase
    
    public init(
        dependency: Dependency
    ) {
        self.navigationController = dependency.navigationController
        self.centerEmployCardVO = dependency.centerEmployCardVO
        self.workerProfileUseCase = dependency.workerProfileUseCase
    }
    
    deinit {
        printIfDebug("\(String(describing: CheckApplicantCoordinator.self))")
    }
    
    public func start() {
        let vc = CheckApplicantVC()
        let vm = CheckApplicantVM(
            postCardVO: centerEmployCardVO, 
            coorindator: self
        )
        vc.bind(viewModel: vm)
        viewControllerRef = vc
        navigationController.pushViewController(vc, animated: true)
    }
}

extension CheckApplicantCoordinator {
    
    public func taskFinished() {
        popViewController()
        parent?.removeChildCoordinator(self)
    }
    
    public func showWorkerProfileScreen(profileId: String) {
        let coordinator = WorkerProfileCoordinator(
            dependency: .init(
                profileMode: .otherProfile(id: profileId),
                navigationController: navigationController,
                workerProfileUseCase: workerProfileUseCase
            )
        )
        addChildCoordinator(coordinator)
        coordinator.start()
    }
}
