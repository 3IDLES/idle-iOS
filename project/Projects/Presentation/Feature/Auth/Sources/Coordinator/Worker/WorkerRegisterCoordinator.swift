//
//  WorkerRegisterCoordinator.swift
//  AuthFeature
//
//  Created by choijunios on 6/30/24.
//

import UIKit
import PresentationCore

enum WorkerRegisterStage: Int {
    
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

public class WorkerRegisterCoordinator: ChildCoordinator {

    public var parent: WorkerAuthCoordinatable?
    
    public let navigationController: UINavigationController
    
    public weak var viewControllerRef: DisposableViewController?
    
    weak var pageViewController: UIPageViewController?
    
    var stageViewControllers: [DisposableViewController] = []
    
    var currentStage: WorkerRegisterStage?
    
    public init(navigationController: UINavigationController) {
    
        self.navigationController = navigationController
        
        self.stageViewControllers = [
//            ValidatePhoneNumberViewController(coordinator: self, viewModel: CenterRegisterViewModel()),
//            EnterNameViewController(coordinator: self, viewModel: CenterRegisterViewModel()),
//            SelectGenderViewController(coordinator: self),
        ]
    }
    
    deinit {
        printIfDebug("deinit \(Self.self)")
    }
    
    public func start() {
        
        let pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        
        self.pageViewController = pageViewController
        
        let viewController = WorkerRegisterViewController(
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

extension WorkerRegisterCoordinator {
    
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
        
        let viewController = stageViewControllers[WorkerRegisterStage.phoneNumber.rawValue]
        
        showStage(viewController: viewController)
        
        currentStage = .phoneNumber
    }
    
    func nameStage() {
        
//        let viewController = stageViewControllers[WorkerRegisterStage.name.rawValue]
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
        
        let viewController = stageViewControllers[WorkerRegisterStage.gender.rawValue]
        
        let genderStage = viewController as! SelectGenderViewController
        
        genderStage.coordinator = self
        
        showStage(viewController: genderStage)
        
        currentStage = .gender
    }
    
    func showStage(viewController: UIViewController) {
        
        pageViewController?.setViewControllers([viewController], direction: .forward, animated: true)
    }
    
    func authFinished() {
        
        stageViewControllers = []
        
        parent?.authFinished()
    }
}
