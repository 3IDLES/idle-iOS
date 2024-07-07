//
//  CenterRegisterCoordinator.swift
//  AuthFeature
//
//  Created by choijunios on 7/1/24.
//

import UIKit
import PresentationCore

enum CenterRegisterStage: Int {
    
    case name=0
    case phoneNumber=1
    case businessOwner=2
    case idPassword=3
    case finish=4
    
    var nextStage: Self? {
        
        switch self {
        case .name:
            return .phoneNumber
        case .phoneNumber:
            return .businessOwner
        case .businessOwner:
            return .idPassword
        case .idPassword:
            return .finish
        default:
            return nil
        }
    }
}

public class CenterRegisterCoordinator: ChildCoordinator {
    
    public var parent: CenterAuthCoordinatable?
    
    public weak var viewControllerRef: (any PresentationCore.DisposableViewController)?
    
    weak var pageViewController: UIPageViewController?
    
    public var navigationController: UINavigationController
    
    var stageViewControllers: [DisposableViewController] = []
    
    private var currentStage: CenterRegisterStage?
    
    public init(
        viewModel: CenterRegisterViewModel,
        navigationController: UINavigationController
    ) {
        self.navigationController = navigationController
        
        // stageViewControllerss에 자기자신과 ViewModel할당
        self.stageViewControllers = [
            EnterNameViewController(coordinator: self, viewModel: viewModel),
            ValidatePhoneNumberViewController(coordinator: self, viewModel: viewModel),
            AuthBusinessOwnerViewController(coordinator: self, viewModel: viewModel),
            SetIdPasswordViewController(coordinator: self, viewModel: viewModel),
        ]
    }
    
    deinit { printIfDebug("deinit \(Self.self)") }
    
    public func start() {
        
        let pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        
        self.pageViewController = pageViewController
        
        let viewController = CenterRegisterViewController(
            pageViewController: pageViewController
        )
        
        viewController.coordinator = self
        
        viewControllerRef = viewController
        
        navigationController.pushViewController(viewController, animated: true)
        
        enterName()
    }
    
    public func coordinatorDidFinish() {
        
        viewControllerRef?.cleanUp()
        
        stageViewControllers = []
        
        popViewController()
        
        parent?.removeChildCoordinator(self)
    }
}

extension CenterRegisterCoordinator {
    
    public func next() {
        
        if let nextStage = currentStage?.nextStage {
            
            switch nextStage {
            case .name:
                enterName()
            case .phoneNumber:
                authPhoneNumber()
            case .businessOwner:
                authBusinessOwner()
            case .idPassword:
                setIdPassword()
            case .finish:
                authFinished()
            default:
                return
            }
        }
    }
    
    func authPhoneNumber() {
        
        let viewController = stageViewControllers[CenterRegisterStage.phoneNumber.rawValue]
        
        showStage(viewController: viewController)
        
        currentStage = .phoneNumber
    }
    
    func enterName() {
        
        let viewController = stageViewControllers[CenterRegisterStage.name.rawValue]
        
        showStage(viewController: viewController)
        
        currentStage = .name
    }
    
    func authBusinessOwner() {
        
        let viewController = stageViewControllers[CenterRegisterStage.businessOwner.rawValue]
        
        showStage(viewController: viewController)
        
        currentStage = .businessOwner
    }
    
    func setIdPassword() {
        
        let viewController = stageViewControllers[CenterRegisterStage.idPassword.rawValue]
        
        showStage(viewController: viewController)
        
        currentStage = .idPassword
    }
    
    func showStage(viewController: UIViewController) {
        
        pageViewController?.setViewControllers([viewController], direction: .forward, animated: true)
    }
    
    func authFinished() {
        
        stageViewControllers = []
        
        parent?.authFinished()
    }
}
