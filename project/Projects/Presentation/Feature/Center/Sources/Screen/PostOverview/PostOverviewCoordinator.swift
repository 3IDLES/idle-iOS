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
    
    public weak var viewControllerRef: UIViewController?
    public weak var parent: ParentCoordinator?
    var registerRecruitmentPostCoordinator: RegisterRecruitmentPostCoordinatable? {
        parent as? RegisterRecruitmentPostCoordinatable
    }
    
    public let navigationController: UINavigationController
    
    public let viewModel: PostOverviewViewModelable
    
    public init(viewModel: PostOverviewViewModelable, navigationController: UINavigationController) {
        self.viewModel = viewModel
        self.navigationController = navigationController
    }
    
    deinit {
        printIfDebug("\(String(describing: PostOverviewCoordinator.self))")
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
        registerRecruitmentPostCoordinator?.showRegisterCompleteScreen()
    }
}
