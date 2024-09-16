//
//  PasswordForDeregisterCoordinator.swift
//  CenterFeature
//
//  Created by choijunios on 8/21/24.
//

import UIKit
import PresentationCore
import UseCaseInterface
import Entity

public class PasswordForDeregisterCoordinator: ChildCoordinator {
    
    public struct Dependency {
        let settingUseCase: SettingScreenUseCase
        let reasons: [String]
        let navigationController: UINavigationController
        
        public init(settingUseCase: SettingScreenUseCase, reasons: [String], navigationController: UINavigationController) {
            self.settingUseCase = settingUseCase
            self.reasons = reasons
            self.navigationController = navigationController
        }
    }
    
    public weak var viewControllerRef: UIViewController?
    public weak var parent: DeregisterCoordinatable?
    
    public let navigationController: UINavigationController
    let settingUseCase: SettingScreenUseCase
    let reasons: [String]
    
    public init(
        dependency: Dependency
    ) {
        self.settingUseCase = dependency.settingUseCase
        self.reasons = dependency.reasons
        self.navigationController = dependency.navigationController
    }
    
    deinit {
        printIfDebug("\(String(describing: PasswordForDeregisterCoordinator.self))")
    }
    
    public func start() {
        let vc = PasswordForDeregisterVC()
        let vm = PasswordForDeregisterVM(
            deregisterReasons: reasons,
            coordinator: self,
            settingUseCase: settingUseCase
        )
        vc.bind(viewModel: vm)
        viewControllerRef = vc
        navigationController.pushViewController(vc, animated: true)
    }
    
    public func coordinatorDidFinish() {
        popViewController()
        parent?.removeChildCoordinator(self)
    }
    
    public func popToRoot() {
        parent?.popToRoot()
    }
    
    public func cancelDeregister() {
        parent?.cancelDeregister()
    }
}

