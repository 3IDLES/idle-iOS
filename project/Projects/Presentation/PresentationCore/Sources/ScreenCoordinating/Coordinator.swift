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
    func popViewController()
}

// MARK: ParentCoordinator
public protocol ParentCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] { get set }
    
    func addChildCoordinator(_ coordinator: Coordinator)
    func removeChildCoordinator(_ coordinator: Coordinator)
}

public extension ParentCoordinator {
    
    func addChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }
    
    func removeChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
    }
}

// MARK: ChildCoordinator
public protocol ChildCoordinator: Coordinator {
    
    var viewControllerRef: DisposableViewController? { get }
    
    func coordinatorDidFinish()
}

