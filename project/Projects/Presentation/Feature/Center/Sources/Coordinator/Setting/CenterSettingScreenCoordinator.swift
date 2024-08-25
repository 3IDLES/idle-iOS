//
//  CenterSettingScreenCoordinator.swift
//  CenterFeature
//
//  Created by choijunios on 8/25/24.
//

import UIKit
import PresentationCore
import UseCaseInterface
import Entity

public class CenterSettingScreenCoordinator: ChildCoordinator {
    
    public struct Dependency {
        let navigationController: UINavigationController
        let settingUseCase: SettingScreenUseCase
        let centerProfileUseCase: CenterProfileUseCase
        
        public init(navigationController: UINavigationController, settingUseCase: SettingScreenUseCase, centerProfileUseCase: CenterProfileUseCase) {
            self.navigationController = navigationController
            self.settingUseCase = settingUseCase
            self.centerProfileUseCase = centerProfileUseCase
        }
    }
    
    public weak var viewControllerRef: UIViewController?
    public weak var parent: CenterSettingScreenCoordinatable?
    
    public let navigationController: UINavigationController
    let settingUseCase: SettingScreenUseCase
    let centerProfileUseCase: CenterProfileUseCase
    
    public init(
        dependency: Dependency
    ) {
        self.navigationController = dependency.navigationController
        self.settingUseCase = dependency.settingUseCase
        self.centerProfileUseCase = dependency.centerProfileUseCase
    }
    
    deinit {
        printIfDebug("\(String(describing: CenterSettingScreenCoordinator.self))")
    }
    
    public func start() {
        let vc = CenterSettingVC()
        let vm = CenterSettingVM(
            coordinator: self,
            settingUseCase: settingUseCase,
            centerProfileUseCase: centerProfileUseCase
        )
        vc.bind(viewModel: vm)
        viewControllerRef = vc
        navigationController.pushViewController(vc, animated: false)
    }
    
    public func coordinatorDidFinish() {
        parent?.removeChildCoordinator(self)
        popViewController()
    }
    
    public func popToRoot() {
        
        /// Root까지 네비게이션을 제거합니다.
        NotificationCenter.default.post(name: .popToInitialVC, object: nil)
    }
    
    public func startRemoveCenterAccountFlow() {
        parent?.startRemoveCenterAccountFlow()
    }
}

