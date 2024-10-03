//
//  WorkerAccountRegisterCoordinator.swift
//  AuthFeature
//
//  Created by choijunios on 10/3/24.
//

import UIKit
import BaseFeature
import PresentationCore
import Core


public class WorkerAccountRegisterCoordinator: Coordinator2 {
    
    // Injected
    @Injected var logger: WorkerRegisterLogger
    
    // PageViewController
    weak var pageViewController: UIPageViewController?
    var stageViewControllers: [UIViewController] = []
    private var currentStage: WorkerRegisterStage!
    
    public init() {
        
    }
    
    public func start() {
        
        let vm = WorkerRegisterViewModel()
        
        self.stageViewControllers = [
            ValidatePhoneNumberViewController(viewModel: vm),
            EntetPersonalInfoViewController(viewModel: vm),
            EnterAddressViewController(viewModel: vm),
        ]
        
        let pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
    }
}
