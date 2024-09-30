//
//  CenterSettingScreenCoordinator.swift
//  CenterFeature
//
//  Created by choijunios on 8/25/24.
//

import UIKit
import PresentationCore
import Domain
import Core

public class CenterSettingScreenCoordinator: ChildCoordinator {
    
    public weak var viewControllerRef: UIViewController?
    public weak var parent: ParentCoordinator?
    
    var centerSettingCoordinator: CenterSettingCoordinatable? {
        parent as? CenterSettingCoordinatable
    }
    
    public let navigationController: UINavigationController
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    deinit {
        printIfDebug("\(String(describing: CenterSettingScreenCoordinator.self))")
    }
    
    public func start() {
        let vc = CenterSettingVC()
        let vm = CenterSettingVM(coordinator: self)
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
        centerSettingCoordinator?.startRemoveCenterAccountFlow()
    }
    
    public func showMyCenterProfile() {
        centerSettingCoordinator?.showMyCenterProfile()
    }
}

