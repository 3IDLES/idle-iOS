//
//  PostOverviewCoordinator.swift
//  CenterFeature
//
//  Created by choijunios on 8/5/24.
//

import UIKit
import PresentationCore
import Domain
import Core

public class PostOverviewCoordinator: ChildCoordinator {
    
    public struct Dependency {
        let navigationController: UINavigationController
        let viewModel: PostOverviewViewModelable
        
        public init(navigationController: UINavigationController, viewModel: PostOverviewViewModelable) {
            self.navigationController = navigationController
            self.viewModel = viewModel
        }
    }
    
    public weak var viewControllerRef: UIViewController?
    public weak var parent: RegisterRecruitmentPostCoordinatable?
    
    public let navigationController: UINavigationController
    
    public let viewModel: PostOverviewViewModelable
    
    public init(dependency: Dependency) {
        self.viewModel = dependency.viewModel
        self.navigationController = dependency.navigationController
    }
    
    deinit {
        printIfDebug("\(String(describing: RegisterRecruitmentCoordinator.self))")
    }
    
    public func start() {
        let vc = PostOverviewVC()
        vc.bind(viewModel: viewModel)
        viewModel.postOverviewCoordinator = self
        viewControllerRef = vc
        navigationController.pushViewController(vc, animated: true)
    }
    
    public func coordinatorDidFinish() {
        popViewController()
        parent?.removeChildCoordinator(self)
    }
}

extension PostOverviewCoordinator {
    func showCompleteScreen() {
        parent?.showRegisterCompleteScreen()
    }
}
