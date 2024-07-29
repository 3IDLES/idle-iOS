//
//  RegisterCenterInfoCoordinator.swift
//  CenterFeature
//
//  Created by choijunios on 7/27/24.
//

import UIKit
import PresentationCore
import UseCaseInterface
import Entity

public class RegisterCenterInfoCoordinator: ChildCoordinator {
    
    public weak var viewControllerRef: UIViewController?
    public weak var parent: CenterProfileRegisterCoordinatable?
    
    public let navigationController: UINavigationController
    
    public let viewModel: RegisterCenterInfoViewModelable
    
    public init(
        profileUseCase: CenterProfileUseCase,
        navigationController: UINavigationController
    ) {
        self.viewModel = RegisterCenterInfoVM(profileUseCase: profileUseCase)
        self.navigationController = navigationController
    }
    
    deinit {
        printIfDebug("\(String(describing: RegisterCenterInfoCoordinator.self))")
    }
    
    public func start() {
        let vc = RegisterCenterInfoVC(coordinator: self)
        vc.bind(viewModel: viewModel)
        
        viewControllerRef = vc
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    public func coordinatorDidFinish() {
        parent?.removeChildCoordinator(self)
    }
}

extension RegisterCenterInfoCoordinator {
    
    func showCompleteScreen(cardVO: CenterProfileCardVO) {
        parent?.showCompleteScreen(cardVO: cardVO)
    }
    
    func registerFinished() {
        parent?.registerFinished()
    }
}
