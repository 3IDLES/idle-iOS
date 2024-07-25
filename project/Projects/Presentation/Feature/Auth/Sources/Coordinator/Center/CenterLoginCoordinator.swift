//
//  CenterLoginCoordinator.swift
//  AuthFeature
//
//  Created by choijunios on 7/1/24.
//

import UIKit
import PresentationCore

public class CenterLoginCoordinator: ChildCoordinator {
    
    public weak var viewControllerRef: UIViewController?

    public var navigationController: UINavigationController
    
    public var parent: CenterAuthCoordinatable?
    
    private var viewModel: CenterLoginViewModel
    
    public init(
        viewModel: CenterLoginViewModel,
        navigationController: UINavigationController
    ) {
        self.navigationController = navigationController
        self.viewModel = viewModel
    }
    
    deinit { printIfDebug("deinit \(Self.self)") }
    
    public func start() {
        
        let viewController = CenterLoginViewController(
            coordinator: self,
            viewModel: viewModel
        )
        viewControllerRef = viewController
        navigationController.pushViewController(viewController, animated: true)
    }
    
    public func coordinatorDidFinish() {
        popViewController()
        parent?.removeChildCoordinator(self)
    }
}

extension CenterLoginCoordinator {
    
    /// 비밀번호 변경창을 종료한 경우
    func findPasswordFinished() {
        popViewController()
    }
    
    /// 로그인창을 종료한 경우
    func loginFinished() {
        popViewController()
        parent?.removeChildCoordinator(self)
    }
    
    /// Auth가 종료된 경우
    func authFinished() {
        parent?.authFinished()
    }
}
