//
//  EditPostCoordinator.swift
//  CenterFeature
//
//  Created by choijunios on 8/14/24.
//

import UIKit
import PresentationCore
import BaseFeature
import UseCaseInterface
import Entity
import DSKit

public class EditPostCoordinator: ChildCoordinator {
    
    public struct Dependency {
        let navigationController: UINavigationController
        let viewModel: EditPostViewModelable
        
        public init(navigationController: UINavigationController, viewModel: EditPostViewModelable) {
            self.navigationController = navigationController
            self.viewModel = viewModel
        }
    }
    
    public weak var viewControllerRef: UIViewController?
    public weak var parent: ParentCoordinator?
    
    public let navigationController: UINavigationController
    public let viewModel: EditPostViewModelable
    
    public init(
        dependency: Dependency
    ) {
        self.navigationController = dependency.navigationController
        self.viewModel = dependency.viewModel
        viewModel.editPostCoordinator = self
    }
    
    deinit {
        printIfDebug("\(String(describing: EditPostCoordinator.self))")
    }
    
    public func start() {
        let vc = EditPostVC()
        vc.bind(viewModel: viewModel)
        viewControllerRef = vc
        navigationController.pushViewController(vc, animated: true)
    }
    
    public func coordinatorDidFinish() {
        popViewController()
        parent?.removeChildCoordinator(self)
    }
    
    func coordinatorDidFinishWithSnackBar(ro: IdleSnackBarRO) {
        let belowIndex = navigationController.children.count-2
        
        if belowIndex >= 0 {
            let belowVC = navigationController.children[belowIndex]
            
            if let baseVC = belowVC as? BaseViewController {
                
                baseVC.viewModel?.addSnackBar(ro: ro)
            }
        }
        
        coordinatorDidFinish()
    }
}

