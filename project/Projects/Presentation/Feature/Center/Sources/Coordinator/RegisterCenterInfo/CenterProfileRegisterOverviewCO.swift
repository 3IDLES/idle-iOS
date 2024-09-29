//
//  CenterProfileRegisterOverviewCO.swift
//  CenterFeature
//
//  Created by choijunios on 9/12/24.
//

import UIKit
import Domain
import PresentationCore
import Core

public class CenterProfileRegisterOverviewCO: ChildCoordinator {
    
    public struct Dependency {
        let navigationController: UINavigationController
        let stateObject: CenterProfileRegisterState
        let profileUseCase: CenterProfileUseCase
        
        public init(navigationController: UINavigationController, stateObject: CenterProfileRegisterState, profileUseCase: CenterProfileUseCase) {
            self.navigationController = navigationController
            self.stateObject = stateObject
            self.profileUseCase = profileUseCase
        }
    }
    
    public weak var viewControllerRef: UIViewController?
    public weak var parent: CenterProfileRegisterCoordinatable?
    
    public let navigationController: UINavigationController
    let stateObject: CenterProfileRegisterState
    let profileUseCase: CenterProfileUseCase
    
    public init(dependency: Dependency) {
        self.navigationController = dependency.navigationController
        self.stateObject = dependency.stateObject
        self.profileUseCase = dependency.profileUseCase
    }
    
    deinit {
        printIfDebug("\(String(describing: RegisterRecruitmentCoordinator.self))")
    }
    
    public func start() {
        let vc = CenterProfileRegisterOverviewVC()
        let vm = RegisterProfileOverviewVM(
            coordinator: self,
            stateObject: stateObject,
            profileUseCase: profileUseCase
        )
        vc.bind(viewModel: vm)
        
        viewControllerRef = vc
        navigationController.pushViewController(vc, animated: true)
    }
    
    public func coordinatorDidFinish() {
        parent?.removeChildCoordinator(self)
        popViewController()
    }
    
    func showCompleteScreen() {
        parent?.showCompleteScreen()
    }
}
