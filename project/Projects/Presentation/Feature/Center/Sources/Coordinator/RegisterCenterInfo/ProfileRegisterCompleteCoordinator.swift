//
//  ProfileRegisterCompleteCoordinator.swift
//  CenterFeature
//
//  Created by choijunios on 7/27/24.
//

import UIKit
import PresentationCore
import UseCaseInterface

public class ProfileRegisterCompleteCoordinator: ChildCoordinator {
    
    public weak var viewControllerRef: UIViewController?
    public weak var parent: CenterProfileRegisterCoordinatable?
    
    public let navigationController: UINavigationController
    
    public init(
        navigationController: UINavigationController
    ) {
        self.navigationController = navigationController
    }
    
    deinit {
        printIfDebug("\(String(describing: RegisterCenterInfoCoordinator.self))")
    }
    
    public func start() {
        let vc = ProfileRegisterCompleteVC(coordinator: self)
        viewControllerRef = vc
        navigationController.pushViewController(vc, animated: true)
    }
    
    public func coordinatorDidFinish() {
        parent?.removeChildCoordinator(self)
    }
}

extension ProfileRegisterCompleteCoordinator {
    
    func showCenterProfile() {
        parent?.showCenterProfile()
    }
    
    func registerFinished() {
        parent?.registerFinished()
    }
}
