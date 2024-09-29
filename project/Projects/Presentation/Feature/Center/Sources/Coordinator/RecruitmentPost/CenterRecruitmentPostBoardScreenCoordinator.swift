//
//  CenterRecruitmentPostBoardScreenCoordinator.swift
//  CenterFeature
//
//  Created by choijunios on 8/25/24.
//

import UIKit
import PresentationCore
import Domain
import Core

public class CenterRecruitmentPostBoardScreenCoordinator: ChildCoordinator {
    
    public struct Dependency {
        let navigationController: UINavigationController
        let recruitmentPostUseCase: RecruitmentPostUseCase
        
        public init(navigationController: UINavigationController, recruitmentPostUseCase: RecruitmentPostUseCase) {
            self.navigationController = navigationController
            self.recruitmentPostUseCase = recruitmentPostUseCase
        }
    }
    
    public weak var viewControllerRef: UIViewController?
    public weak var parent: RecruitmentManagementCoordinatable?
    
    public let navigationController: UINavigationController
    let recruitmentPostUseCase: RecruitmentPostUseCase
    
    public init(dependency: Dependency) {
        self.navigationController = dependency.navigationController
        self.recruitmentPostUseCase = dependency.recruitmentPostUseCase
    }
    
    deinit {
        printIfDebug("\(String(describing: RegisterRecruitmentCoordinator.self))")
    }
    
    public func start() {
        let vc = CenterRecruitmentPostBoardVC()
        let vm = CenterRecruitmentPostBoardVM(
            coordinator: self,
            recruitmentPostUseCase: recruitmentPostUseCase
        )
        vc.bind(viewModel: vm)
        viewControllerRef = vc
        navigationController.pushViewController(vc, animated: false)
    }
    
    public func coordinatorDidFinish() {
        popViewController()
        parent?.removeChildCoordinator(self)
    }
    
    public func showCheckingApplicantScreen(postId: String) {
        parent?.showCheckingApplicantScreen(postId: postId)
    }
    
    public func showPostDetailScreenForCenter(postId: String, postState: PostState) {
        
        parent?.showPostDetailScreenForCenter(postId: postId, postState: postState)
    }
    
    public func showEditScreen(postId: String) {
        parent?.showEditScreen(postId: postId)
    }
    
    public func showRegisterPostScreen() {
        parent?.showRegisterPostScrean()
    }
}

