//
//  CenterMainPageCoordinator.swift
//  CenterMainPageFeature
//
//  Created by choijunios on 10/3/24.
//

import UIKit
import BaseFeature
import Core
import Domain

public class CenterPostBoardPageCoordinator: Coordinator2 {
    
    let router: Router
    let tabController: UINavigationController
    
    public var startFLow: ((CenterMainPageInternalDestination) -> ())!
    
    public init(router: Router, tabController: UINavigationController) {
        self.router = router
        self.tabController = tabController
    }
    
    public func start() {
        let viewModel = PostBoardPageViewModel()
        viewModel.presentRegisterPostPage = { [weak self] in
            self?.startFLow(.registerPostPage)
        }
        viewModel.createPostCellViewModel = { [weak self] info, state in
            
            let cellViewModel = CenterEmployCardVM(
                postInfo: info,
                postState: state
            )
            cellViewModel.presentPostDetailPage = { [weak self] id, state in
                
                self?.startFLow(.postDetailPage(postId: id, postState: state))
            }
            cellViewModel.presentPostApplicantPage = { [weak self] id in
                
                self?.startFLow(.postApplicantPage(postId: id))
            }
            cellViewModel.presentPostEditPage = { [weak self] id in
                
                self?.startFLow(.postEditPage(postId: id))
            }
            
            return cellViewModel
        }
        
        let viewController = PostBoardPageViewController()
        viewController.bind(viewModel: viewModel)
        
        router.push(
            module: viewController,
            to: tabController,
            animated: false
        )
    }
}
