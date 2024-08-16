//
//  Coordinator.swift
//  BaseFeature
//
//  Created by choijunios on 8/15/24.
//

import UIKit
import PresentationCore
import UseCaseInterface
import Entity

public class PostDetailForWorkerCoodinator: ChildCoordinator {
    
    public struct Dependency {
        let postId: String
        weak var parent: WorkerRecruitmentBoardCoordinatable?
        let navigationController: UINavigationController
        let recruitmentPostUseCase: RecruitmentPostUseCase
        
        public init(postId: String, parent: WorkerRecruitmentBoardCoordinatable? = nil, navigationController: UINavigationController, recruitmentPostUseCase: RecruitmentPostUseCase) {
            self.postId = postId
            self.parent = parent
            self.navigationController = navigationController
            self.recruitmentPostUseCase = recruitmentPostUseCase
        }
    }
    
    public weak var viewControllerRef: UIViewController?
    public weak var parent: WorkerRecruitmentBoardCoordinatable?
    
    let postId: String
    public let navigationController: UINavigationController
    let recruitmentPostUseCase: RecruitmentPostUseCase
    
    public init(
        dependency: Dependency
    ) {
        self.postId = dependency.postId
        self.parent = dependency.parent
        self.navigationController = dependency.navigationController
        self.recruitmentPostUseCase = dependency.recruitmentPostUseCase
    }
    
    deinit {
        printIfDebug("\(String(describing: PostDetailForWorkerCoodinator.self))")
    }
    
    public func start() {
        let vc = PostDetailForWorkerVC()
        let vm = PostDetailForWorkerVM(
            postId: postId,
            coordinator: self,
            recruitmentPostUseCase: recruitmentPostUseCase
        )
        vc.bind(viewModel: vm)
        viewControllerRef = vc
        navigationController.pushViewController(vc, animated: true)
    }
    
    public func coordinatorDidFinish() {
        popViewController()
        parent?.removeChildCoordinator(self)
    }
}

extension PostDetailForWorkerCoodinator {
    
    func showCenterProfileScreen(centerId: String) {
        parent?.showCenterProfile(centerId: centerId)
    }
}
