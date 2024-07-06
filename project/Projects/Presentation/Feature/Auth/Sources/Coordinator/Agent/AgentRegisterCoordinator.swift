//
//  AgentRegisterCoordinator.swift
//  AuthFeature
//
//  Created by choijunios on 6/30/24.
//

import UIKit
import PresentationCore

enum AgentRegisterStage: Int {
    
    case phoneNumber=0
    case name=1
    case gender=2
    case finish=3
    
    var nextStage: Self? {
        
        switch self {
        case .phoneNumber:
            return .name
        case .name:
            return .gender
        case .gender:
            return .finish
        default:
            return nil
        }
    }
}

public class AgentRegisterCoordinator: ChildCoordinator {

    public var parent: AgentAuthCoordinatable?
    
    public let navigationController: UINavigationController
    
    public weak var viewControllerRef: DisposableViewController?
    
    weak var pageViewController: UIPageViewController?
    
    var stageViewControllers: [DisposableViewController] = []
    
    var currentStage: AgentRegisterStage?
    
    public init(navigationController: UINavigationController) {
    
        self.navigationController = navigationController
    }
    
    deinit {
        printIfDebug("deinit \(Self.self)")
    }
    
    public func start() {
        
        stageViewControllers = [
            ValidatePhoneNumberViewController(coordinator: self, viewModel: CenterRegisterViewModel()),
            EnterNameViewController(coordinator: self, viewModel: CenterRegisterViewModel()),
            SelectGenderViewController(coordinator: self),
        ]
        
        let pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        
        self.pageViewController = pageViewController
        
        let viewController = AgentRegisterViewController(
            pageViewController: pageViewController
        )
        
        viewController.coordinator = self
        
        viewControllerRef = viewController
        
        navigationController.pushViewController(viewController, animated: true)
        
        phoneNumberStage()
    }

    public func coordinatorDidFinish() {
        
        viewControllerRef?.cleanUp()
        
        parent?.removeChildCoordinator(self)
    }
}

extension AgentRegisterCoordinator {
    
    public func next() {
        
        if let nextStage = currentStage?.nextStage {
            
            switch nextStage {
            case .name:
                nameStage()
            case .gender:
                genderStage()
            case .finish:
                authFinished()
            default:
                return
            }
        }
    }
    
    func phoneNumberStage() {
        
        let viewController = stageViewControllers[AgentRegisterStage.phoneNumber.rawValue]
        
        showStage(viewController: viewController)
        
        currentStage = .phoneNumber
    }
    
    func nameStage() {
        
//        let viewController = stageViewControllers[AgentRegisterStage.name.rawValue]
//        
//        let nameStage = viewController as! EnterNameViewController
//        
//        nameStage.coordinator = self
//
//        showStage(viewController: nameStage)
//        
//        currentStage = .name
    }
    
    func genderStage() {
        
        let viewController = stageViewControllers[AgentRegisterStage.gender.rawValue]
        
        let genderStage = viewController as! SelectGenderViewController
        
        genderStage.coordinator = self
        
        showStage(viewController: genderStage)
        
        currentStage = .gender
    }
    
    func showStage(viewController: UIViewController) {
        
        pageViewController?.setViewControllers([viewController], direction: .forward, animated: true)
    }
    
    func authFinished() {
        
        parent?.authFinished()
    }
}
