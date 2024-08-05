//
//  PostOverviewCoordinator.swift
//  CenterFeature
//
//  Created by choijunios on 8/5/24.
//

import UIKit
import PresentationCore
import UseCaseInterface
import Entity

public class PostOverviewCoordinator: ChildCoordinator {
    
    public weak var viewControllerRef: UIViewController?
    public weak var parent: RegisterRecruitmentPostCoordinatable?
    
    public let navigationController: UINavigationController
    
    public let viewModel: RegisterRecruitmentPostViewModelable
    
    public init(
        viewModel: RegisterRecruitmentPostViewModelable,
        navigationController: UINavigationController
    ) {
        self.viewModel = viewModel
        self.navigationController = navigationController
    }
    
    deinit {
        printIfDebug("\(String(describing: RegisterRecruitmentCoordinator.self))")
    }
    
    public func start() {
        let vc = PostOverviewVC()
        vc.coordinator = self
        vc.bind(viewModel: viewModel)
        viewControllerRef = vc
        navigationController.pushViewController(vc, animated: true)
    }
    
    public func coordinatorDidFinish() {
        parent?.removeChildCoordinator(self)
    }
}

extension PostOverviewCoordinator {
    
    func showCompleteScreen() {
            
    }
    
    func backToEditScreen() {
        popViewController()
        coordinatorDidFinish()
    }
}
