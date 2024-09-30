//
//  WorkerProfileCoordinator.swift
//  WorkerFeature
//
//  Created by choijunios on 8/14/24.
//

import UIKit
import PresentationCore
import Domain
import Core

public class WorkerProfileCoordinator: ChildCoordinator {
    
    public weak var viewControllerRef: UIViewController?
    public weak var parent: ParentCoordinator?
    
    let profileMode: ProfileMode
    public let navigationController: UINavigationController
    
    public init(profileMode: ProfileMode, navigationController: UINavigationController) {
        
        self.profileMode = profileMode
        self.navigationController = navigationController
    }
    
    deinit {
        printIfDebug("\(String(describing: WorkerProfileCoordinator.self))")
    }
    
    public func start() {
        let vc = WorkerProfileViewController()
        
        switch profileMode {
        case .myProfile:
            let vm = WorkerMyProfileViewModel(coordinator: self)
            vc.bind(vm)
        case .otherProfile(let id):
            let vm = WorkerProfileViewModel(coordinator: self, workerId: id)
            vc.bind(vm)
        }
        viewControllerRef = vc
        navigationController.pushViewController(vc, animated: true)
    }
    
    public func coordinatorDidFinish() {
        popViewController(animated: true)
        parent?.removeChildCoordinator(self)
    }
}
