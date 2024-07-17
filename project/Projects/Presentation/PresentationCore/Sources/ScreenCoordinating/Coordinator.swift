//
//  Coordinator.swift
//  PresentationCore
//
//  Created by 최준영 on 6/21/24.
//

import UIKit

// MARK: Coordinator
public protocol Coordinator: AnyObject {
    
    var navigationController: UINavigationController { get }
    
    func start()
    func next()
    func prev()
    func popViewController(animated: Bool)
}

public extension Coordinator {
    
    func popViewController(animated: Bool = true) {
        
        navigationController.popViewController(animated: animated)
    }
    
    func next() { }
    func prev() { }
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
    }
    
    func removeChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
    }
    
    func clearChildren() {
        
        print(self, childCoordinators, navigationController.viewControllers)
        
        let lastCoordinator = childCoordinators.popLast()
        
        var middleViewControllers: [UIViewController?] = []
        
        childCoordinators.reversed().forEach { coordinator in
            
            if coordinator is ChildCoordinator {
                
                let child = coordinator as! ChildCoordinator
                
                child.viewControllerRef?.cleanUp()
                
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
                
                if lastCoordinator is ChildCoordinator {
                    
                    (lastCoordinator as! ChildCoordinator).viewControllerRef?.cleanUp()
                }
                
                self.removeChildCoordinator(lastCoordinator)
                lastCoordinator.popViewController()
            }
        }
        
        print("종료", self, childCoordinators, navigationController.viewControllers)
    }
}

// MARK: ChildCoordinator
public protocol ChildCoordinator: Coordinator {
    
    var viewControllerRef: DisposableViewController? { get }
    
    func coordinatorDidFinish()
}

