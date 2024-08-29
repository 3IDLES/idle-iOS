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
        let postId: String
        let navigationController: UINavigationController
        let recruitmentPostUseCase: RecruitmentPostUseCase
        let workerProfileUseCase: WorkerProfileUseCase
        
        public init(postId: String, navigationController: UINavigationController, recruitmentPostUseCase: RecruitmentPostUseCase, workerProfileUseCase: WorkerProfileUseCase) {
            self.postId = postId
            self.navigationController = navigationController
            self.recruitmentPostUseCase = recruitmentPostUseCase
            self.workerProfileUseCase = workerProfileUseCase
        }
    }
    
    public weak var viewControllerRef: UIViewController?
    public weak var parent: ParentCoordinator?
    
    let postId: String
    public let navigationController: UINavigationController
    let workerProfileUseCase: WorkerProfileUseCase
    let recruitmentPostUseCase: RecruitmentPostUseCase
    
    public init(
        dependency: Dependency
    ) {
        self.postId = dependency.postId
        self.navigationController = dependency.navigationController
        self.workerProfileUseCase = dependency.workerProfileUseCase
        self.recruitmentPostUseCase = dependency.recruitmentPostUseCase
    }
    
    deinit {
        printIfDebug("\(String(describing: CheckApplicantCoordinator.self))")
    }
    
    public func start() {
        let vc = CheckApplicantVC()
        let vm = CheckApplicantVM(
            postId: postId,
            coorindator: self,
            recruitmentPostUseCase: recruitmentPostUseCase
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
