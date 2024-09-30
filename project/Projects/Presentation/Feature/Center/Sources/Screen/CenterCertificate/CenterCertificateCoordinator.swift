//
//  CenterCertificateCoordinator.swift
//  CenterFeature
//
//  Created by choijunios on 9/11/24.
//

import UIKit
import PresentationCore
import Domain
import Core

public class CenterCertificateCoordinator: ChildCoordinator {
    
    public weak var viewControllerRef: UIViewController?
    public weak var parent: ParentCoordinator?
    var rootCoordinator: RootCoorinatable? {
        parent as? RootCoorinatable
    }
    
    public let navigationController: UINavigationController

    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    deinit {
        printIfDebug("\(String(describing: CenterCertificateCoordinator.self))")
    }
    
    public func start() {
        let vc = CenterCertificateIntroductionVC()
        let vm = CenterCertificateIntroVM(coordinator: self)
        vc.bind(viewModel: vm)
        viewControllerRef = vc
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showProfileRegisterScreen() {
        rootCoordinator?.makeCenterProfile()
    }
    
    public func coordinatorDidFinish() {
        rootCoordinator?.removeChildCoordinator(self)
        popViewController()
    }
}
