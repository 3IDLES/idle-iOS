//
//  Coordinator.swift
//  BaseFeature
//
//  Created by choijunios on 8/15/24.
//

import UIKit
import PresentationCore
import Domain
import Core

public class PostDetailForWorkerCoodinator: ChildCoordinator {
    
    public struct Dependency {
        let postType: RecruitmentPostType
        let postId: String
        weak var parent: WorkerRecruitmentBoardCoordinatable?
        let navigationController: UINavigationController
        let recruitmentPostUseCase: RecruitmentPostUseCase
        let workerProfileUseCase: WorkerProfileUseCase
        let centerProfileUseCase: CenterProfileUseCase
        
        public init(
            postType: RecruitmentPostType,
            postId: String,
            parent: WorkerRecruitmentBoardCoordinatable? = nil,
            navigationController: UINavigationController,
            recruitmentPostUseCase: RecruitmentPostUseCase,
            workerProfileUseCase: WorkerProfileUseCase,
            centerProfileUseCase: CenterProfileUseCase
        ) {
            self.postType = postType
            self.postId = postId
            self.parent = parent
            self.navigationController = navigationController
            self.recruitmentPostUseCase = recruitmentPostUseCase
            self.workerProfileUseCase = workerProfileUseCase
            self.centerProfileUseCase = centerProfileUseCase
        }
    }
    
    public weak var viewControllerRef: UIViewController?
    public weak var parent: WorkerRecruitmentBoardCoordinatable?
    
    let postType: RecruitmentPostType
    let postId: String
    public let navigationController: UINavigationController
    let recruitmentPostUseCase: RecruitmentPostUseCase
    let workerProfileUseCase: WorkerProfileUseCase
    let centerProfileUseCase: CenterProfileUseCase
    
    public init(
        dependency: Dependency
    ) {
        self.postType = dependency.postType
        self.postId = dependency.postId
        self.parent = dependency.parent
        self.navigationController = dependency.navigationController
        self.recruitmentPostUseCase = dependency.recruitmentPostUseCase
        self.workerProfileUseCase = dependency.workerProfileUseCase
        self.centerProfileUseCase = dependency.centerProfileUseCase
    }
    
    deinit {
        printIfDebug("\(String(describing: PostDetailForWorkerCoodinator.self))")
    }
    
    public func start() {
        
        var vc: UIViewController!
        
        switch postType {
        case .native:
            let nativeDetailVC = NativePostDetailForWorkerVC()
            let vm = NativePostDetailForWorkerVM(
                postId: postId,
                coordinator: self,
                recruitmentPostUseCase: recruitmentPostUseCase, 
                workerProfileUseCase: workerProfileUseCase,
                centerProfileUseCase: centerProfileUseCase
            )
            nativeDetailVC.bind(viewModel: vm)
            vc = nativeDetailVC
        case .workNet:
            let worknetDetailVC = WorknetPostDetailForWorkerVC()
            let vm = WorknetPostDetailForWorkerVM(
                postId: postId,
                coordinator: self,
                recruitmentPostUseCase: recruitmentPostUseCase,
                workerProfileUseCase: workerProfileUseCase
            )
            worknetDetailVC.bind(viewModel: vm)
            vc = worknetDetailVC
        }
        
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
