//
//  TestVC.swift
//  Idle-iOS
//
//  Created by choijunios on 6/30/24.
//

import UIKit
import DSKit
import PresentationCore

// MARK: Test MainTabBar
class TestMainTabBarCoodinator: ChildCoordinator {
    
    var navigationController: UINavigationController
    
    var parent: RootCoordinator?
    
    weak var viewControllerRef: UIViewController?
    
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
    
    func startAuth() {
        
        parent?.auth()
    }
}

public class TestMainTabBarController: DisposableViewController {
    
    var coordinator: TestMainTabBarCoodinator?
    
    lazy var startLoginButton = ButtonPrototype(text: "로그인 시작") { [weak self] in
        self?.coordinator?.startAuth()
    }
    
    public func cleanUp() {
        
        coordinator?.coordinatorDidFinish()
    }
    
    public override func viewDidLoad() {
        
        let titleLabel = UILabel()
        
        titleLabel.text = "테스트용 메인 탭바 화면입니다."
        
        view.backgroundColor = .white
        
        [
            titleLabel,
            startLoginButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        view.layoutMargins = .init(top: 0, left: 20, bottom: 0, right: 20)
        
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            startLoginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            startLoginButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            startLoginButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])
    }
}
