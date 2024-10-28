//
//  PopToDismissNC.swift
//  BaseFeature
//
//  Created by choijunios on 10/28/24.
//

import UIKit

public class PopToDismissNavigationController: UINavigationController {
    
    private var duringTransition = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        interactivePopGestureRecognizer?.delegate = self
        delegate = self
    }
    
    public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        duringTransition = true
        
        super.pushViewController(viewController, animated: animated)
    }
    
}

extension PopToDismissNavigationController: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        self.duringTransition = false
    }
}

extension PopToDismissNavigationController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == interactivePopGestureRecognizer,
              let _ = topViewController else {
            return true // default value
        }
        
        return viewControllers.count > 1 && duringTransition == false
    }
}
