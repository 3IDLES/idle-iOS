//
//  WorkerRecruitmentBoardCoordinator.swift
//  RootFeature
//
//  Created by choijunios on 7/25/24.
//

import UIKit
import PresentationCore

public protocol WorkerRecruitmentBoardCoordinatable: ParentCoordinator {
    /// 요양보호사가 볼 수 있는 공고 상세정보를 표시합니다.
    func showPostDetail(postId: String)
    
    /// 센터 프로필을 표시합니다.
    func showCenterProfile(centerId: String)
}

public class WorkerRecruitmentBoardCoordinator: WorkerRecruitmentBoardCoordinatable {
    
    public struct Dependency {
        let navigationController: UINavigationController
    }
    
    public var childCoordinators: [any PresentationCore.Coordinator] = []
    
    public weak var viewControllerRef: UIViewController?
    
    public var navigationController: UINavigationController
    
    weak var parent: ParentCoordinator?
    
    public init(depedency: Dependency) {
        self.navigationController = depedency.navigationController
    }
    
    public func start() {
        let vc = RecruitmentBoardVC()
        
        navigationController.pushViewController(vc, animated: false)
    }
    
    public func coordinatorDidFinish() {
        popViewController()
        parent?.removeChildCoordinator(self)
    }
}

extension WorkerRecruitmentBoardCoordinator {
    public func showPostDetail(postId: String) {
        
    }
    public func showCenterProfile(centerId: String) {
        
    }
}

