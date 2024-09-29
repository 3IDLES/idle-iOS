//
//  SelectReasonCoordinator.swift
//  RootFeature
//
//  Created by choijunios on 8/21/24.
//

import UIKit
import PresentationCore
import Domain
import Core

public class SelectReasonCoordinator: ChildCoordinator {
    
    public struct Dependency {
        let userType: UserType
        let settingUseCase: SettingScreenUseCase
        let navigationController: UINavigationController
        
        public init(userType: UserType, settingUseCase: SettingScreenUseCase, navigationController: UINavigationController) {
            self.userType = userType
            self.settingUseCase = settingUseCase
            self.navigationController = navigationController
        }
    }
    
    public weak var viewControllerRef: UIViewController?
    public var navigationController: UINavigationController
    public weak var parent: DeregisterCoordinatable?
    
    let userType: UserType
    let settingUseCase: SettingScreenUseCase
    
    public init(dependency: Dependency) {
        self.userType = dependency.userType
        self.settingUseCase = dependency.settingUseCase
        self.navigationController = dependency.navigationController
    }
    
    deinit {
        printIfDebug("\(String(describing: SelectReasonCoordinator.self))")
    }
    
    public func start() {
        var vm: DeregisterReasonVMable!
        switch userType {
        case .center:
            vm = CenterDeregisterReasonsVM(coordinator: self)
        case .worker:
            vm = WorkerDeregisterReasonsVM(coordinator: self)
        }
        
        let vc = DeregisterReasonVC()
        vc.bind(viewModel: vm)
        viewControllerRef = vc
        navigationController.pushViewController(vc, animated: true)
    }
    
    public func coordinatorDidFinish() {
        popViewController()
        parent?.removeChildCoordinator(self)
    }
    
    public func showPasswordAuthScreen(reasons: [String]) {
        parent?.showFinalPasswordScreen(reasons: reasons)
    }
    
    public func showPhoneNumberAuthScreen(reasons: [String]) {
        parent?.showFinalPhoneAuthScreen(reasons: reasons)
    }
}

