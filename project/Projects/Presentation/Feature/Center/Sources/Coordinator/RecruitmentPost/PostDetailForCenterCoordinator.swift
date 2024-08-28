//
//  PostDetailForCenterCoordinator.swift
//  CenterFeature
//
//  Created by choijunios on 8/14/24.
//

import UIKit
import PresentationCore
import UseCaseInterface
import Entity

public class PostDetailForCenterCoordinator: ChildCoordinator {
    
    public struct Dependency {
        let postId: String
        let postState: PostState
        let navigationController: UINavigationController
        let recruitmentPostUseCase: RecruitmentPostUseCase
        
        public init(postId: String, postState: PostState, navigationController: UINavigationController, recruitmentPostUseCase: RecruitmentPostUseCase) {
            self.postId = postId
            self.postState = postState
            self.navigationController = navigationController
            self.recruitmentPostUseCase = recruitmentPostUseCase
        }
    }
    
    public weak var viewControllerRef: UIViewController?
    public weak var parent: RecruitmentManagementCoordinatable?
    
    public let navigationController: UINavigationController
    let postId: String
    let recruitmentPostUseCase: RecruitmentPostUseCase
    
    public init(
        dependency: Dependency
    ) {
        self.navigationController = dependency.navigationController
        self.postId = dependency.postId
        self.recruitmentPostUseCase = dependency.recruitmentPostUseCase
    }
    
    deinit {
        printIfDebug("\(String(describing: PostDetailForCenterCoordinator.self))")
    }
    
    public func start() {
        let vc = PostDetailForCenterVC()
        let vm = PostDetailForCenterVM(
            id: postId,
            coordinator: self,
            recruitmentPostUseCase: recruitmentPostUseCase
        )
        viewControllerRef = vc
        vc.bind(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }
    
    public func coordinatorDidFinish() {
        popViewController()
        parent?.removeChildCoordinator(self)
    }
}

extension PostDetailForCenterCoordinator {
    
    func showPostEditScreen(postId: String) {
        parent?.showEditScreen(postId: postId)
    }
    func showCheckApplicantScreen(postId: String) {
        parent?.showCheckingApplicantScreen(postId: postId)
    }
}
