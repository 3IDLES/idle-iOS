//
//  CenterProfileCoordinator.swift
//  CenterFeature
//
//  Created by choijunios on 7/29/24.
//

import UIKit
import PresentationCore
import UseCaseInterface
import Entity

/// 내센터, 다른 센터를 모두 불러올 수 있습니다.
public class CenterProfileCoordinator: ChildCoordinator {
    
    public struct Dependency {
        let mode: ProfileMode
        let profileUseCase: CenterProfileUseCase
        let navigationController: UINavigationController
        
        public init(mode: ProfileMode, profileUseCase: CenterProfileUseCase, navigationController: UINavigationController) {
            self.mode = mode
            self.profileUseCase = profileUseCase
            self.navigationController = navigationController
        }
    }

    public weak var viewControllerRef: UIViewController?
    public weak var parent: ParentCoordinator?
    
    public let navigationController: UINavigationController
    let mode: ProfileMode
    let profileUseCase: CenterProfileUseCase
    
    public init(dependency: Dependency) {
        self.mode = dependency.mode
        self.profileUseCase = dependency.profileUseCase
        self.navigationController = dependency.navigationController
    }
    
    public func start() {
        let vc = CenterProfileViewController(coordinator: self)
        let vm = CenterProfileViewModel(mode: mode, useCase: profileUseCase)
        vc.bind(viewModel: vm)
        self.viewControllerRef = vc
        navigationController.pushViewController(vc, animated: true)
    }
    
    public func coordinatorDidFinish() {
        popViewController()
        parent?.removeChildCoordinator(self)
    }
}
