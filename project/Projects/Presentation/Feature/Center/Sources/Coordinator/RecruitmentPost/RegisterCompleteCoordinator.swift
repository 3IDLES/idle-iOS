//
//  RegisterCompleteCoordinator.swift
//  CenterFeature
//
//  Created by choijunios on 8/6/24.
//

import UIKit
import PresentationCore
import UseCaseInterface
import Entity

public class RegisterCompleteCoordinator: ChildCoordinator {
    
    public weak var viewControllerRef: UIViewController?
    public weak var parent: RegisterRecruitmentPostCoordinatable?
    
    public let navigationController: UINavigationController
    
    
    public init(
        navigationController: UINavigationController
    ) {
        self.navigationController = navigationController
    }
    
    deinit {
        printIfDebug("\(String(describing: RegisterRecruitmentCoordinator.self))")
    }
    
    public func start() {
        let vc = PostRegisterCompleteVC()
        vc.coordinator = self
        viewControllerRef = vc
        navigationController.pushViewController(vc, animated: true)
    }
    
    public func coordinatorDidFinish() {
        parent?.removeChildCoordinator(self)
    }
    
    func registerFinished() {
        parent?.registerFinished()
    }
}

