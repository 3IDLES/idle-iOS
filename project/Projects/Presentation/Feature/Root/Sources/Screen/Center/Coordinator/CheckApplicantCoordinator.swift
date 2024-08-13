//
//  CheckApplicantCoordinator.swift
//  RootFeature
//
//  Created by choijunios on 8/13/24.
//

import UIKit
import PresentationCore
import UseCaseInterface
import Entity
import CenterFeature
import WorkerFeature
import BaseFeature

public class CheckApplicantCoordinator: ParentCoordinator {
    
    public var childCoordinators: [any PresentationCore.Coordinator] = []
    
    public struct Dependency {
        let navigationController: UINavigationController
        let centerEmployCardVO: CenterEmployCardVO
    }
    
    public weak var viewControllerRef: UIViewController?
    public weak var parent: ParentCoordinator?
    
    public let navigationController: UINavigationController
    let centerEmployCardVO: CenterEmployCardVO
    
    
    public init(
        dependency: Dependency
    ) {
        self.navigationController = dependency.navigationController
        self.centerEmployCardVO = dependency.centerEmployCardVO
    }
    
    deinit {
        printIfDebug("\(String(describing: RegisterRecruitmentCoordinator.self))")
    }
    
    public func start() {
        let vc = CheckApplicantVC()
        let vm = CheckApplicantVM(
            postCardVO: centerEmployCardVO
        )
        vc.bind(viewModel: vm)
        viewControllerRef = vc
        navigationController.pushViewController(vc, animated: true)
    }
    
    public func coordinatorDidFinish() {
        parent?.removeChildCoordinator(self)
    }
}
