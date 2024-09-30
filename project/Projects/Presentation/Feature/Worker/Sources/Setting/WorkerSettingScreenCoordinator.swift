//
//  WorkerSettingScreenCoordinator.swift
//  WorkerFeature
//
//  Created by choijunios on 8/25/24.
//

import UIKit
import PresentationCore
import Domain
import Core

public class WorkerSettingScreenCoordinator: ChildCoordinator {
    
    public weak var viewControllerRef: UIViewController?
    public weak var parent: ParentCoordinator?
    var workerSettingScreenCoordinator: WorkerSettingScreenCoordinatable? {
        parent as? WorkerSettingScreenCoordinatable
    }
    
    public let navigationController: UINavigationController
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    deinit {
        printIfDebug("\(String(describing: WorkerSettingScreenCoordinator.self))")
    }
    
    
    public func start() {
        let vc = WorkerSettingVC()
        let vm = WorkerSettingVM(coordinator: self)
        vc.bind(viewModel: vm)
        viewControllerRef = vc
        navigationController.pushViewController(vc, animated: false)
    }
    
    public func coordinatorDidFinish() {
        parent?.removeChildCoordinator(self)
        popViewController()
    }
    
    func popToRoot() {
           
        /// Root까지 네비게이션을 제거합니다.
        NotificationCenter.default.post(name: .popToInitialVC, object: nil)
    }
    
    func startRemoveWorkerAccountFlow() {
        workerSettingScreenCoordinator?.startRemoveWorkerAccountFlow()
    }
    
    func showMyProfileScreen() {
        workerSettingScreenCoordinator?.showMyProfileScreen()
    }
}
