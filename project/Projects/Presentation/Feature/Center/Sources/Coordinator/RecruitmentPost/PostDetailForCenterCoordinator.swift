//
//  PostDetailForCenterCoordinator.swift
//  CenterFeature
//
//  Created by choijunios on 8/14/24.
//

import UIKit
import BaseFeature
import PresentationCore
import Domain
import DSKit
import Core

public class PostDetailForCenterCoordinator: ChildCoordinator {

    public weak var viewControllerRef: UIViewController?
    public weak var parent: ParentCoordinator?
    
    var recruitmentManagementCoordinator: RecruitmentManagementCoordinatable? {
        parent as? RecruitmentManagementCoordinatable
    }
    
    public let navigationController: UINavigationController
    let postId: String
    let postState: PostState
    
    public init(
        postId: String,
        postState: PostState,
        navigationController: UINavigationController
    ) {
        self.postId = postId
        self.postState = postState
        self.navigationController = navigationController
    }
    
    deinit {
        printIfDebug("\(String(describing: PostDetailForCenterCoordinator.self))")
    }
    
    public func start() {
        let vc = PostDetailForCenterVC()
        let vm = PostDetailForCenterVM(
            postId: postId,
            postState: postState,
            coordinator: self
        )
        viewControllerRef = vc
        vc.bind(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }
    
    public func coordinatorDidFinish() {
        popViewController()
        parent?.removeChildCoordinator(self)
    }
    
    public func coordinatorDidFinishWithSnackBar(ro: IdleSnackBarRO) {
        let belowIndex = navigationController.children.count-2
        
        if belowIndex >= 0 {
            let belowVC = navigationController.children[belowIndex]
            
            if let baseVC = belowVC as? BaseViewController {
                
                baseVC.viewModel?.addSnackBar(ro: ro)
            }
        }
        
        coordinatorDidFinish()
    }
}

extension PostDetailForCenterCoordinator {
    
    func showPostEditScreen(postId: String) {
        recruitmentManagementCoordinator?.showEditScreen(postId: postId)
    }
    func showCheckApplicantScreen(postId: String) {
        recruitmentManagementCoordinator?.showCheckingApplicantScreen(postId: postId)
    }
}
