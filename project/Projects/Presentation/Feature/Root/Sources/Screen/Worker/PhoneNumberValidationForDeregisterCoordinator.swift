//
//  PhoneNumberValidationForDeregisterCoordinator.swift
//  RootFeature
//
//  Created by choijunios on 8/25/24.
//

import UIKit
import PresentationCore
import Domain


class PhoneNumberValidationForDeregisterCoordinator: ChildCoordinator {
    
    struct Dependency {
        let settingUseCase: SettingScreenUseCase
        let inputValidationUseCase: AuthInputValidationUseCase
        let reasons: [String]
        let navigationController: UINavigationController
        
        init(settingUseCase: SettingScreenUseCase, inputValidationUseCase: AuthInputValidationUseCase, reasons: [String], navigationController: UINavigationController) {
            self.settingUseCase = settingUseCase
            self.inputValidationUseCase = inputValidationUseCase
            self.reasons = reasons
            self.navigationController = navigationController
        }
    }
    
    let settingUseCase: SettingScreenUseCase
    let inputValidationUseCase: AuthInputValidationUseCase
    let reasons: [String]
    
    weak var viewControllerRef: UIViewController?
    weak var parent: DeregisterCoordinatable?
    
    let navigationController: UINavigationController
    
    
    init(
        dependency: Dependency
    ) {
        self.navigationController = dependency.navigationController
        self.settingUseCase = dependency.settingUseCase
        self.inputValidationUseCase = dependency.inputValidationUseCase
        self.reasons = dependency.reasons
    }
    
    deinit {
        printIfDebug("\(String(describing: PhoneNumberValidationForDeregisterCoordinator.self))")
    }
    
    func start() {
        let vc = PhoneNumberValidationForDeregisterVC()
        let vm = PhoneNumberValidationForDeregisterVM(
            coordinator: self,
            deregisterReasons: reasons,
            inputValidationUseCase: inputValidationUseCase,
            settingUseCase: settingUseCase
        )
        vc.bind(viewModel: vm)
        viewControllerRef = vc
        navigationController.pushViewController(vc, animated: true)
    }
    
    func coordinatorDidFinish() {
        popViewController()
        parent?.removeChildCoordinator(self)
    }
    
    func popToRoot() {
        parent?.popToRoot()
    }
    
    func cancelDeregister() {
        parent?.cancelDeregister()
    }
}

