//
//  CenterMainPageCoordinator.swift
//  CenterMainPageFeature
//
//  Created by choijunios on 10/3/24.
//

import UIKit
import BaseFeature
import Domain
import Core

public enum CenterMainPageCoordinatorDestination {
    case workerProfilePage(id: String)
    case createPostPage
    case authFlow
    case myCenterProfilePage
    case accountDeregisterPage
}

public class CenterMainPageCoordinator: BaseCoordinator {
    
    let router: Router
    
    public var startFlow: ((CenterMainPageCoordinatorDestination) -> ())!
    
    public init(router: Router) {
        self.router = router
        super.init()
    }
    
    public override func start() {
        
        let pageInfo = CenterMainPageTab.allCases.map { tab in
            
            let navigationController = createNavForTab(tab: tab)
            
            return IdleTabBar.PageTabItemInfo(
                page: tab,
                navigationController: navigationController
            )
        }
        
        let tabBarModule = IdleTabBar(
            initialPage: CenterMainPageTab.postBoard,
            info: pageInfo
        )
        
        router.replaceRootModuleTo(module: tabBarModule, animated: true) { [weak self] in
            self?.onFinish?()
        }
    }
}

// MARK: Setup tab pages
extension CenterMainPageCoordinator {
    
    func createNavForTab(tab: CenterMainPageTab) -> UINavigationController {
        
        let tabNavController = UINavigationController()
        tabNavController.setNavigationBarHidden(true, animated: false)
        
        startTabCoordinator(
            tab: tab,
            navigationController: tabNavController
        )
        
        return tabNavController
    }
    
    func startTabCoordinator(tab: CenterMainPageTab, navigationController: UINavigationController) {
        
        switch tab {
        case .postBoard:
            presentPostBoardPage(controller: navigationController)
        case .setting:
            presentSettingPage(controller: navigationController)
        }
    }
}

// MARK: TabPageFlow
public extension CenterMainPageCoordinator {
    
    /// 포스트 보드
    func presentPostBoardPage(controller: UINavigationController) {
        
        let viewModel = PostBoardPageViewModel()
        viewModel.presentRegisterPostPage = { [weak self] in
            self?.startFlow(.createPostPage)
        }
        viewModel.createPostCellViewModel = { [weak self] info, state in
            
            let cellViewModel = CenterEmployCardVM(
                postInfo: info,
                postState: state
            )
            cellViewModel.presentPostDetailPage = { [weak self] id, state in
                self?.presentPostDetailPage(postId: id, postState: state)
            }
            cellViewModel.presentPostApplicantPage = { [weak self] id in
                self?.presentPostApplicantPage(postId: id)
            }
            cellViewModel.presentPostEditPage = { [weak self] id in
                self?.presentPostEditPage(postId: id)
            }
            
            return cellViewModel
        }
        
        let viewController = PostBoardPageViewController()
        viewController.bind(viewModel: viewModel)
        
        router.push(
            module: viewController,
            to: controller,
            animated: false
        )
    }
    
    /// 세팅화면
    func presentSettingPage(controller: UINavigationController) {
        
        let viewModel = CenterSettingViewModel()
        viewModel.changeToAuthFlow = { [weak self] in
            self?.startFlow(.authFlow)
        }
        viewModel.presentMyProfile = { [weak self] in
            self?.startFlow(.myCenterProfilePage)
        }
        viewModel.presentAccountDeregisterPage = { [weak self] in
            self?.startFlow(.accountDeregisterPage)
        }
        
        let viewController = CenterSettingViewController()
        viewController.bind(viewModel: viewModel)
        
        router.push(
            module: viewController,
            to: controller,
            animated: false
        )
    }
}

// MARK: SubPages
extension CenterMainPageCoordinator {
    
    public func presentPostApplicantPage(postId: String) {
        
        let viewModel = PostApplicantViewModel(postId: postId)
        viewModel.createCellViewModel = { applicantVO in
            
            let cellViewModel = ApplicantCardVM(vo: applicantVO)
            
            cellViewModel.presentApplicantDetail = { [weak self] applicantId in
                
                self?.startFlow(.workerProfilePage(id: applicantId))
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
    
    public func presentPostEditPage(postId: String) {
        let viewModel = EditPostVM(id: postId)
        viewModel.exitPage = { [weak self] in
            self?.router.popModule(animated: true)
        }
        viewModel.exitPageWithSnackBar = { [weak self] (object, padding) in
            self?.router.popModule(animated: true)
            self?.router.presentSnackBarController(bottomPadding: padding, object: object)
        }
        
        let viewController = EditPostVC()
        viewController.bind(viewModel: viewModel)
        router.push(module: viewController, animated: true)
    }
    
    public func presentPostDetailPage(postId: String, postState: PostState) {
        let viewModel = PostDetailViewModel(postId: postId, postState: postState)
        
        viewModel.presentApplicantPage = { [weak self] postId in
            self?.presentPostApplicantPage(postId: postId)
        }
        viewModel.presentPostEditPage = { [weak self] postId in
            self?.presentPostEditPage(postId: postId)
        }
        viewModel.exitPage = { [weak self] in
            self?.router.popModule(animated: true)
        }
        viewModel.exitWithSnackBar = { [weak self] object, padding in
            self?.router.popModule(animated: true)
            self?.router.presentSnackBarController(bottomPadding: padding, object: object)
        }
        
        let viewController = PostDetailForCenterVC()
        viewController.bind(viewModel: viewModel)

        router.push(module: viewController, animated: true)
    }
}
