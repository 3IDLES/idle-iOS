//
//  CenterProfileCoordinator.swift
//  CenterFeature
//
//  Created by choijunios on 7/29/24.
//

import UIKit
import PresentationCore
import UseCaseInterface
import Entity

/// 내센터, 다른 센터를 모두 불러올 수 있습니다.
public class CenterProfileCoordinator: ChildCoordinator {

    public weak var viewControllerRef: UIViewController?
    public weak var parent: CenterProfileRegisterCoordinatable?
    
    public let navigationController: UINavigationController
    
    public let viewModel: any CenterProfileViewModelable
    
    public init(
        mode: ProfileMode,
        profileUseCase: CenterProfileUseCase,
        navigationController: UINavigationController
    ) {
        self.viewModel = CenterProfileViewModel(mode: mode, useCase: profileUseCase)
        self.navigationController = navigationController
    }
    
    public func start() {
        let vc = CenterProfileViewController(coordinator: self)
        vc.bind(viewModel: viewModel)
        self.viewControllerRef = vc
        navigationController.pushViewController(vc, animated: true)
    }
    
    public func coordinatorDidFinish() {
        parent?.removeChildCoordinator(self)
    }
    
    func closeViewController() {
        popViewController()
        coordinatorDidFinish()
    }
}
