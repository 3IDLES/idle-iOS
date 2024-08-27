//
//  CenterRecruitmentPostBoardScreenCoordinator.swift
//  CenterFeature
//
//  Created by choijunios on 8/25/24.
//

import UIKit
import PresentationCore
import UseCaseInterface
import Entity

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
    
    public func showPostDetailScreenForCenter(postId: String) {
        
        // MARK: 수정
        fatalError()
        
        parent?.showPostDetailScreenForCenter(postId: postId, applicantCount: 1)
    }
    
    public func showEditScreen(postId: String) {
        parent?.showEditScreen(postId: postId)
    }
}

