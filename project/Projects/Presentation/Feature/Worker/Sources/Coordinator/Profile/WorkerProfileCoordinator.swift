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
    
    public struct Dependency {
        public let profileMode: ProfileMode
        public let navigationController: UINavigationController
        public let workerProfileUseCase: WorkerProfileUseCase
        
        public init(profileMode: ProfileMode, navigationController: UINavigationController, workerProfileUseCase: WorkerProfileUseCase) {
            self.profileMode = profileMode
            self.navigationController = navigationController
            self.workerProfileUseCase = workerProfileUseCase
        }
    }
    
    public weak var viewControllerRef: UIViewController?
    public weak var parent: ParentCoordinator?
    
    public let navigationController: UINavigationController
    let profileMode: ProfileMode
    let workerProfileUseCase: WorkerProfileUseCase
    
    public init(
        dependency: Dependency
    ) {
        self.navigationController = dependency.navigationController
        self.profileMode = dependency.profileMode
        self.workerProfileUseCase = dependency.workerProfileUseCase
    }
    
    deinit {
        printIfDebug("\(String(describing: WorkerProfileCoordinator.self))")
    }
    
    public func start() {
        let vc = WorkerProfileViewController()
        
        switch profileMode {
        case .myProfile:
            let vm = WorkerMyProfileViewModel(
                coordinator: self,
                workerProfileUseCase: workerProfileUseCase
            )
            vc.bind(vm)
        case .otherProfile(let id):
            let vm = WorkerProfileViewModel(
                coordinator: self,
                workerProfileUseCase: workerProfileUseCase,
                workerId: id
            )
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
