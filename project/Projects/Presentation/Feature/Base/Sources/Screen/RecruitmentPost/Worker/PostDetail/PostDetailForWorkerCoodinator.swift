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
    
    
    public weak var viewControllerRef: UIViewController?
    public weak var parent: ParentCoordinator?
    
    var workerRecruitmentBoardCoordinator: WorkerRecruitmentBoardCoordinatable? {
        parent as? WorkerRecruitmentBoardCoordinatable
    }
    
    let postInfo: RecruitmentPostInfo
    public let navigationController: UINavigationController
    
    public init(postInfo: RecruitmentPostInfo, navigationController: UINavigationController) {
        self.postInfo = postInfo
        self.navigationController = navigationController
    }
    
    deinit {
        printIfDebug("\(String(describing: PostDetailForWorkerCoodinator.self))")
    }
    
    public func start() {
        
        var vc: UIViewController!
        
        switch postInfo.type {
            
        case .native:
            let nativeDetailVC = NativePostDetailForWorkerVC()
            let vm = NativePostDetailForWorkerVM(
                postInfo: postInfo,
                coordinator: self
            )
            nativeDetailVC.bind(viewModel: vm)
            vc = nativeDetailVC
            
        case .workNet:
            let worknetDetailVC = WorknetPostDetailForWorkerVC()
            let vm = WorknetPostDetailForWorkerVM(
                postInfo: postInfo,
                coordinator: self
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
        workerRecruitmentBoardCoordinator?.showCenterProfile(centerId: centerId)
    }
}
