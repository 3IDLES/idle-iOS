//
//  AppCoordinator.swift
//  Idle-iOS
//
//  Created by choijunios on 6/28/24.
//

import UIKit
import PresentationCore

class RootCoordinator: ParentCoordinator {
    
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        
        let coordinator = TestMainTabBarCoodinator(
            navigationController: navigationController
        )
        
        coordinator.parent = self
        addChildCoordinator(coordinator)
        
        coordinator.start()
    }
    
    func popViewController() {
        navigationController.popViewController(animated: false)
    }
}


// MARK: Test MainTabBar
class TestMainTabBarCoodinator: ChildCoordinator {
    
    var navigationController: UINavigationController
    
    var parent: RootCoordinator?
    
    weak var viewControllerRef: DisposableViewController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        
        let viewController = TestMainTabBarController()
        viewController.coordinator = self
        
        self.viewControllerRef = viewController
        
        navigationController.pushViewController(viewController, animated: false)
    }
    
    func popViewController() {
        
        navigationController.popViewController(animated: true)
    }
    
    func coordinatorDidFinish() {
        
        parent?.removeChildCoordinator(self)
    }
}

public class TestMainTabBarController: DisposableViewController {
    
    var coordinator: TestMainTabBarCoodinator?
    
    public func cleanUp() {
        
        coordinator?.coordinatorDidFinish()
    }
    
    public override func viewDidLoad() {
        
        let initialLabel = UILabel()
        
        initialLabel.text = "테스트용 메인 탭바 화면입니다."
        
        view.backgroundColor = .white
        
        view.addSubview(initialLabel)
        initialLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            initialLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            initialLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}
