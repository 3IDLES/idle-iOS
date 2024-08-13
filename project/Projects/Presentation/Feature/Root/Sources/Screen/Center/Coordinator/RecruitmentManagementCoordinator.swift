//
//  RecruitmentManagementCoordinator.swift
//  RootFeature
//
//  Created by choijunios on 7/25/24.
//

import UIKit
import CenterFeature
import PresentationCore
import Entity


public class RecruitmentManagementCoordinator: RecruitmentManagementCoordinatable {
    
    public var childCoordinators: [any PresentationCore.Coordinator] = []
    
    public weak var viewControllerRef: UIViewController?
    
    public var navigationController: UINavigationController
    
    public weak var parent: CenterMainCoordinatable?
    
    public init(
        parent: CenterMainCoordinatable,
        navigationController: UINavigationController
    ) {
        self.parent = parent
        self.navigationController = navigationController
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
                centerEmployCardVO: centerEmployCardVO
            )
        )
        addChildCoordinator(coordinator)
        coordinator.parent = self
        coordinator.start()
    }
}
