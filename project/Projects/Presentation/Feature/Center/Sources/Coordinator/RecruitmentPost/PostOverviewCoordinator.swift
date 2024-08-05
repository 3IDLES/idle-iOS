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
    public weak var parent: CenterProfileRegisterCoordinatable?
    
    public let navigationController: UINavigationController
    
    public let viewModel: RegisterRecruitmentPostViewModelable
    
    public init(
        navigationController: UINavigationController
    ) {
        self.viewModel = RegisterRecruitmentPostVM()
        self.navigationController = navigationController
    }
    
    deinit {
        printIfDebug("\(String(describing: RegisterRecruitmentCoordinator.self))")
    }
    
    public func start() {
        let vc = PostOverviewVC()
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    public func coordinatorDidFinish() {
        parent?.removeChildCoordinator(self)
    }
}

extension PostOverviewCoordinator {
    
    func showCompleteScreen() {
        
        
    }
}
