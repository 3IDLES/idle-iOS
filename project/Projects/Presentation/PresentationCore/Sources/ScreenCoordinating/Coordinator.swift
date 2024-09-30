//
//  Coordinator.swift
//  PresentationCore
//
//  Created by 최준영 on 6/21/24.
//

import UIKit
import Core

// MARK: Coordinator
public protocol Coordinator: AnyObject {
    
    var parent: ParentCoordinator? { get set }
    var navigationController: UINavigationController { get }
    
    func start()
    func popViewController(animated: Bool)
}

public extension Coordinator {
    
    func popViewController(animated: Bool = true) {
        navigationController.popViewController(animated: animated)
    }
}

// MARK: ParentCoordinator
public protocol ParentCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] { get set }
    
    func addChildCoordinator(_ coordinator: Coordinator)
    func removeChildCoordinator(_ coordinator: Coordinator)
    
    func clearChildren()
}

public extension ParentCoordinator {
    
    func addChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
        coordinator.parent = self
    }
    
    func removeChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
    }
    
    func clearChildren() {
        
        printIfDebug(self, childCoordinators, navigationController.viewControllers)
        
        let lastCoordinator = childCoordinators.popLast()
        
        var middleViewControllers: [UIViewController?] = []
        
        childCoordinators.reversed().forEach { coordinator in
            
            if coordinator is ChildCoordinator {
                
                let child = coordinator as! ChildCoordinator
                
                if let middleViewController = child.viewControllerRef {
                    
                    middleViewControllers.append(middleViewController)
                }
                
                self.removeChildCoordinator(child)
            }
        }
        
        navigationController.viewControllers = navigationController.viewControllers.filter({ viewController in
            !middleViewControllers.contains(where: { $0 === viewController })
        })
        
        if lastCoordinator is ParentCoordinator {
            
            (lastCoordinator as! ParentCoordinator).clearChildren()

        } else {
            
            if let lastCoordinator {
                
                self.removeChildCoordinator(lastCoordinator)
                lastCoordinator.popViewController()
            }
        }
        
        print("종료", self, childCoordinators, navigationController.viewControllers)
    }
}

// MARK: ChildCoordinator
public protocol ChildCoordinator: Coordinator {
    
    var viewControllerRef: UIViewController? { get }
    
    func coordinatorDidFinish()
}

