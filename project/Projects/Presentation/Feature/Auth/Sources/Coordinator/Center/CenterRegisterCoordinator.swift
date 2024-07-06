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
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    deinit { printIfDebug("deinit \(Self.self)") }
    
    public func start() {
        stageViewControllers = [
            EnterNameViewController(),
            ValidatePhoneNumberViewController(),
            AuthBusinessOwnerViewController(),
            SetIdPasswordViewController(),
        ]
        
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
        
        parent?.removeChildCoordinator(self)
    }
}

extension CenterRegisterCoordinator {
    
    func next() {
        
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
        
        let phoneStage = viewController as! ValidatePhoneNumberViewController
        
        phoneStage.coordinater = self
        
        showStage(viewController: phoneStage)
        
        currentStage = .phoneNumber
    }
    
    func enterName() {
        
        let viewController = stageViewControllers[CenterRegisterStage.name.rawValue]
        
        let nameStage = viewController as! EnterNameViewController
        
        nameStage.coordinater = self
        
        showStage(viewController: nameStage)
        
        currentStage = .name
    }
    
    func authBusinessOwner() {
        
        let viewController = stageViewControllers[CenterRegisterStage.businessOwner.rawValue]
        
        let nameStage = viewController as! AuthBusinessOwnerViewController
        
        nameStage.coordinater = self
        
        showStage(viewController: nameStage)
        
        currentStage = .businessOwner
    }
    
    func setIdPassword() {
        
        let viewController = stageViewControllers[CenterRegisterStage.idPassword.rawValue]
        
        let nameStage = viewController as! SetIdPasswordViewController
        
        nameStage.coordinater = self
        
        showStage(viewController: nameStage)
        
        currentStage = .idPassword
    }
    
    func showStage(viewController: UIViewController) {
        
        pageViewController?.setViewControllers([viewController], direction: .forward, animated: true)
    }
    
    func authFinished() {
        
        parent?.authFinished()
    }
}
