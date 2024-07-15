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
    case address=3
    case finish=4
    
    var nextStage: Self? {
        return .init(rawValue: rawValue+1)
    }
}

public class WorkerRegisterCoordinator: ChildCoordinator {

    public var parent: WorkerAuthCoordinatable?
    
    public let navigationController: UINavigationController
    
    public weak var viewControllerRef: DisposableViewController?
    
    weak var pageViewController: UIPageViewController?
    
    var stageViewControllers: [DisposableViewController] = []
    
    var currentStage: WorkerRegisterStage?
    
    public init(
        navigationController: UINavigationController,
        viewModel: WorkerRegisterViewModel
    ) {
    
        self.navigationController = navigationController
        
        self.stageViewControllers = [
            EnterNameViewController(coordinator: self, viewModel: viewModel),
            SelectGenderViewController(coordinator: self, viewModel: viewModel),
            ValidatePhoneNumberViewController(coordinator: self, viewModel: viewModel),
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
            case .address:
                return
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
        
        let viewController = stageViewControllers[WorkerRegisterStage.name.rawValue]

        showStage(viewController: viewController)
        
        currentStage = .name
    }
    
    func genderStage() {
        
        let viewController = stageViewControllers[WorkerRegisterStage.gender.rawValue]
        
        showStage(viewController: viewController)
        
        currentStage = .gender
    }
    
    func addressStage() {
        
        currentStage = .address
    }
    
    func showStage(viewController: UIViewController) {
        
        pageViewController?.setViewControllers([viewController], direction: .forward, animated: true)
    }
    
    func authFinished() {
        
        stageViewControllers = []
        
        parent?.authFinished()
    }
}
