//
//  CenterCertificateCoordinator.swift
//  CenterFeature
//
//  Created by choijunios on 9/11/24.
//

import UIKit
import PresentationCore
import UseCaseInterface
import Entity

public class CenterCertificateCoordinator: ChildCoordinator {
    
    enum Navigation {
        case requestProfileInfo
        case certificationOnGoing
        case certificateOnBoarding
    }
    
    public struct Dependency {
        let navigationController: UINavigationController
        let centerCertificateUseCase: CenterCertificateUseCase
        
        public init(navigationController: UINavigationController, centerCertificateUseCase: CenterCertificateUseCase) {
            self.navigationController = navigationController
            self.centerCertificateUseCase = centerCertificateUseCase
        }
    }
    
    public weak var viewControllerRef: UIViewController?
    public weak var parent: ParentCoordinator?
    
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
    
    public func coordinatorDidFinish() {
        parent?.removeChildCoordinator(self)
        popViewController()
    }
}
