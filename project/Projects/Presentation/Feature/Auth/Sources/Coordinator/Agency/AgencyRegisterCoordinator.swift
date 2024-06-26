//
//  AgencyRegisterCoordinator.swift
//  AuthFeature
//
//  Created by choijunios on 7/1/24.
//

import UIKit
import PresentationCore

enum AgencyRegisterStage: Int {
    
    case phoneNumber=0
    case name=1
    case businessOwner=2
    case idPassword=3
    case finish=4
    
    var nextStage: Self? {
        
        switch self {
        case .phoneNumber:
            return .name
        case .name:
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

public class AgencyRegisterCoordinator: ChildCoordinator {
    
    public var parent: AgencyAuthCoordinatable?
    
    public weak var viewControllerRef: (any PresentationCore.DisposableViewController)?
    
    weak var pageViewController: UIPageViewController?
    
    public var navigationController: UINavigationController
    
    var stageViewControllers: [DisposableViewController] = []
    
    private var currentStage: AgencyRegisterStage?
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    deinit { printIfDebug("deinit \(Self.self)") }
    
    public func start() {
        stageViewControllers = [
            ValidatePhoneNumberViewController(),
            EnterNameViewController(),
            AuthBusinessOwnerViewController(),
            SetIdPasswordViewController(),
        ]
        
        let pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        
        self.pageViewController = pageViewController
        
        let viewController = AgencyRegisterViewController(
            pageViewController: pageViewController
        )
        
        viewController.coordinator = self
        
        viewControllerRef = viewController
        
        navigationController.pushViewController(viewController, animated: true)
        
        authPhoneNumber()
    }
    
    public func coordinatorDidFinish() {
    
        viewControllerRef?.cleanUp()
        
        parent?.removeChildCoordinator(self)
    }
}

extension AgencyRegisterCoordinator {
    
    func next() {
        
        if let nextStage = currentStage?.nextStage {
            
            switch nextStage {
            case .phoneNumber:
                authPhoneNumber()
            case .name:
                enterName()
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
        
        let viewController = stageViewControllers[AgencyRegisterStage.phoneNumber.rawValue]
        
        let phoneStage = viewController as! ValidatePhoneNumberViewController
        
        phoneStage.coordinater = self
        
        showStage(viewController: phoneStage)
        
        currentStage = .phoneNumber
    }
    
    func enterName() {
        
        let viewController = stageViewControllers[AgencyRegisterStage.name.rawValue]
        
        let nameStage = viewController as! EnterNameViewController
        
        nameStage.coordinater = self
        
        showStage(viewController: nameStage)
        
        currentStage = .name
    }
    
    func authBusinessOwner() {
        
        let viewController = stageViewControllers[AgencyRegisterStage.businessOwner.rawValue]
        
        let nameStage = viewController as! AuthBusinessOwnerViewController
        
        nameStage.coordinater = self
        
        showStage(viewController: nameStage)
        
        currentStage = .businessOwner
    }
    
    func setIdPassword() {
        
        let viewController = stageViewControllers[AgencyRegisterStage.idPassword.rawValue]
        
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
