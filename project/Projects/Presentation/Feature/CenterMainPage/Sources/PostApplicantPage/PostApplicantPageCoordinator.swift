//
//  PostApplicantPageCoordinator.swift
//  CenterMainPageFeature
//
//  Created by choijunios on 10/3/24.
//

import Foundation
import BaseFeature
import Domain
import Core

enum PostApplicantPageCoordinatorDestination {
    case applicantDetail(id: String)
}

class PostApplicantPageCoordinator: Coordinator {
    
    var onFinish: (() -> ())?
    
    let postId: String
    let router: Router
    
    var startFlow: ((PostApplicantPageCoordinatorDestination) -> ())!
    
    init(router: Router, postId: String) {
        self.router = router
        self.postId = postId
    }
    
    func start() {
        let viewModel = PostApplicantViewModel(postId: postId)
        viewModel.createCellViewModel = { applicantVO in
            
            let cellViewModel = ApplicantCardVM(vo: applicantVO)
            
            cellViewModel.presentApplicantDetail = { [weak self] applicantId in
                
                self?.startFlow(.applicantDetail(id: applicantId))
            }
            
            return cellViewModel
        }
        viewModel.exitPage = { [weak self] in
            self?.router.popModule(animated: true)
        }
        
        let viewController = PostApplicantViewController()
        viewController.bind(viewModel: viewModel)
        
        router.push(module: viewController, animated: true)
    }
}
