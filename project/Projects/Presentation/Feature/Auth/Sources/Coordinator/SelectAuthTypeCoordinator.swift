//
//  SelectAuthTypeCoordinator.swift
//  AuthFeature
//
//  Created by choijunios on 6/30/24.
//

import UIKit
import PresentationCore
import Core

public class SelectAuthTypeCoordinator: ChildCoordinator {
    
    public var navigationController: UINavigationController
    
    public weak var viewControllerRef: UIViewController?
    
    public var parent: AuthCoordinatable?
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() {
        let vc = SelectAuthTypeViewController()
        let vm = SelectAuthTypeViewModel(coordinator: self)
        vc.bind(viewModel: vm)
        viewControllerRef = vc
        navigationController.pushViewController(vc, animated: true)
    }
    
    public func coordinatorDidFinish() {
        popViewController()
        parent?.removeChildCoordinator(self)
    }
    
    deinit {
        printIfDebug("deinit \(Self.self)")
    }
}

extension SelectAuthTypeCoordinator {
    
    func startCenterLoginFlow() {
        parent?.startCenterLoginFlow()
    }
    func registerAsCenter() {
        parent?.registerAsCenter()
    }
    func registerAsWorker() {
        parent?.registerAsWorker()
    }
}
