//
//  CenterProfileRegisterOverviewCO.swift
//  CenterFeature
//
//  Created by choijunios on 9/12/24.
//

import UIKit
import Domain
import PresentationCore
import Core

public class CenterProfileRegisterOverviewCoordinator: ChildCoordinator {

    public weak var viewControllerRef: UIViewController?
    public weak var parent: ParentCoordinator?
    var centerProfileRegisterCoordinator: CenterProfileRegisterCoordinatable? {
        parent as? CenterProfileRegisterCoordinatable
    }
    
    public let navigationController: UINavigationController
    let stateObject: CenterProfileRegisterState
    
    public init(navigationController: UINavigationController, stateObject: CenterProfileRegisterState) {
        self.navigationController = navigationController
        self.stateObject = stateObject
    }
    
    deinit {
        printIfDebug("\(String(describing: CenterProfileRegisterOverviewCoordinator.self))")
    }
    
    public func start() {
        let vc = CenterProfileRegisterOverviewVC()
        let vm = RegisterProfileOverviewVM(
            coordinator: self,
            stateObject: stateObject
        )
        vc.bind(viewModel: vm)
        
        viewControllerRef = vc
        navigationController.pushViewController(vc, animated: true)
    }
    
    public func coordinatorDidFinish() {
        parent?.removeChildCoordinator(self)
        popViewController()
    }
    
    func showCompleteScreen() {
        centerProfileRegisterCoordinator?.showCompleteScreen()
    }
}
