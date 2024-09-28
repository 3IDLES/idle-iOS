//
//  CenterCertificateCoordinator.swift
//  CenterFeature
//
//  Created by choijunios on 9/11/24.
//

import UIKit
import PresentationCore
import Domain

public class CenterCertificateCoordinator: ChildCoordinator {
    
    public struct Dependency {
        let navigationController: UINavigationController
        let centerCertificateUseCase: CenterCertificateUseCase
        
        public init(navigationController: UINavigationController, centerCertificateUseCase: CenterCertificateUseCase) {
            self.navigationController = navigationController
            self.centerCertificateUseCase = centerCertificateUseCase
        }
    }
    
    public weak var viewControllerRef: UIViewController?
    public weak var parent: RootCoorinatable?
    
    public let navigationController: UINavigationController
    let centerCertificateUseCase: CenterCertificateUseCase
    
    public init(dependency: Dependency) {
        self.navigationController = dependency.navigationController
        self.centerCertificateUseCase = dependency.centerCertificateUseCase
    }
    
    deinit {
        printIfDebug("\(String(describing: RegisterRecruitmentCoordinator.self))")
    }
    
    public func start() {
        let vc = CenterCertificateIntroductionVC()
        let vm = CenterCertificateIntroVM(
            centerCertificateUseCase: centerCertificateUseCase,
            coordinator: self
        )
        vc.bind(viewModel: vm)
        viewControllerRef = vc
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showProfileRegisterScreen() {
        parent?.makeCenterProfile()
    }
    
    public func coordinatorDidFinish() {
        parent?.removeChildCoordinator(self)
        popViewController()
    }
}
