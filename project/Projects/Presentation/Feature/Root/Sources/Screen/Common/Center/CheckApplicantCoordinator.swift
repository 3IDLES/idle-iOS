//
//  CheckApplicantCoordinator.swift
//  RootFeature
//
//  Created by choijunios on 8/13/24.
//

import UIKit
import PresentationCore
import CenterFeature
import WorkerFeature
import Domain
import BaseFeature
import Core

public class CheckApplicantCoordinator: CheckApplicantCoordinatable {
    
    public var childCoordinators: [any PresentationCore.Coordinator] = []
    
    public weak var viewControllerRef: UIViewController?
    public weak var parent: ParentCoordinator?
    
    let postId: String
    public let navigationController: UINavigationController
    
    public init(
        postId: String,
        navigationController: UINavigationController
    ) {
        self.postId = postId
        self.navigationController = navigationController
    }
    
    deinit {
        printIfDebug("\(String(describing: CheckApplicantCoordinator.self))")
    }
    
    public func start() {
        let vc = CheckApplicantVC()
        let vm = CheckApplicantVM(
            postId: postId,
            coorindator: self
        )
        vc.bind(viewModel: vm)
        viewControllerRef = vc
        navigationController.pushViewController(vc, animated: true)
    }
}

extension CheckApplicantCoordinator {
    
    public func taskFinished() {
        popViewController()
        parent?.removeChildCoordinator(self)
    }
    
    public func showWorkerProfileScreen(profileId: String) {
        let coordinator = WorkerProfileCoordinator(
            profileMode: .otherProfile(id: profileId),
            navigationController: navigationController
        )
        addChildCoordinator(coordinator)
        coordinator.start()
    }
}
