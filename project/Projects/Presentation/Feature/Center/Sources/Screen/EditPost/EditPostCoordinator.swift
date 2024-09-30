//
//  EditPostCoordinator.swift
//  CenterFeature
//
//  Created by choijunios on 8/14/24.
//

import UIKit
import PresentationCore
import BaseFeature
import Domain
import DSKit
import Core

public class EditPostCoordinator: ChildCoordinator {
    
    public weak var viewControllerRef: UIViewController?
    public weak var parent: ParentCoordinator?
    
    public let navigationController: UINavigationController
    public let viewModel: EditPostViewModelable
    
    public init(
        viewModel: EditPostViewModelable,
        navigationController: UINavigationController
    ) {
        self.viewModel = viewModel
        self.navigationController = navigationController
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

