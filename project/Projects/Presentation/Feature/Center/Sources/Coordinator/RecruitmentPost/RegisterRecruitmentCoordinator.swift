//
//  RegisterRecruitmentCoordinator.swift
//  CenterFeature
//
//  Created by choijunios on 8/2/24.
//

import UIKit
import PresentationCore
import Domain
import Core


public class RegisterRecruitmentCoordinator: ChildCoordinator {
    
    public weak var viewControllerRef: UIViewController?
    public weak var parent: ParentCoordinator?
    var registerRecruitmentPostCoordinator: RegisterRecruitmentPostCoordinatable? {
        parent as? RegisterRecruitmentPostCoordinatable
    }
    
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
        let vc = RegisterRecruitmentPostVC()
        vc.bind(viewModel: viewModel)
        viewControllerRef = vc
        navigationController.pushViewController(vc, animated: true)
    }
    
    public func coordinatorDidFinish() {
        parent?.removeChildCoordinator(self)
    }
}

extension RegisterRecruitmentCoordinator {
    
    func showOverViewScreen() {
        registerRecruitmentPostCoordinator?.showOverViewScreen()
    }
    
    func registerFinished() {
        registerRecruitmentPostCoordinator?.registerFinished()
    }
}
