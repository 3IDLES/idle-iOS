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

class PostDetailCoordinator: Coordinator2 {
    
    let router: Router
    let postId: String
    let postState: PostState
    
    init(
        router: Router,
        postId: String,
        postState: PostState
    ) {
        self.router = router
        self.postId = postId
        self.postState = postState
    }
    
    deinit {
        printIfDebug("\(String(describing: PostDetailCoordinator.self))")
    }
    
    func start() {
        
        let viewModel = PostDetailViewModel(postId: postId, postState: postState)
        
//        viewModel.presentApplicantPage
//        viewModel.presentPostEditPage
//        viewModel.exitPage
//        viewModel.exitWithSnackBar
        
        let viewController = PostDetailForCenterVC()
        viewController.bind(viewModel: viewModel)

        router.push(module: viewController, animated: true)
    }
}
