//
//  WorkerRecruitmentBoardCoordinator.swift
//  RootFeature
//
//  Created by choijunios on 7/25/24.
//

import UIKit
import WorkerFeature
import PresentationCore
import UseCaseInterface

public class WorkerRecruitmentBoardCoordinator: WorkerRecruitmentBoardCoordinatable {
    
    public struct Dependency {
        let navigationController: UINavigationController
        let centerProfileUseCase: CenterProfileUseCase
        let recruitmentPostUseCase: RecruitmentPostUseCase
        
        public init(navigationController: UINavigationController, centerProfileUseCase: CenterProfileUseCase, recruitmentPostUseCase: RecruitmentPostUseCase) {
            self.navigationController = navigationController
            self.centerProfileUseCase = centerProfileUseCase
            self.recruitmentPostUseCase = recruitmentPostUseCase
        }
    }
    
    public var childCoordinators: [any PresentationCore.Coordinator] = []
    
    public weak var viewControllerRef: UIViewController?
    
    public var navigationController: UINavigationController
    
    weak var parent: ParentCoordinator?
    
    let centerProfileUseCase: CenterProfileUseCase
    let recruitmentPostUseCase: RecruitmentPostUseCase
    
    public init(depedency: Dependency) {
        self.navigationController = depedency.navigationController
        self.centerProfileUseCase = depedency.centerProfileUseCase
        self.recruitmentPostUseCase = depedency.recruitmentPostUseCase
    }
    
    public func start() {
        let vc = WorkerRecruitmentPostBoardVC()
        let vm = WorkerRecruitmentPostBoardVM(
            coordinator: self
        )
        vc.bind(viewModel: vm)
        navigationController.pushViewController(vc, animated: false)
    }
    
    public func coordinatorDidFinish() {
        popViewController()
        parent?.removeChildCoordinator(self)
    }
}

extension WorkerRecruitmentBoardCoordinator {
    public func showPostDetail(postId: String) {
        
    }
    public func showCenterProfile(centerId: String) {
        
    }
}

