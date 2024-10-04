//
//  WorkerMainPageCoordinator.swift
//  WorkerMainPageFeature
//
//  Created by choijunios on 10/4/24.
//

import UIKit
import BaseFeature
import Domain
import Core

public enum WorkerMainPageCoordinatorDestination {
    case postDetailPage(id: String, type: PostOriginType)
    case authFlow
    case myProfilePage
    case accountDeregisterPage
}

public class WorkerMainPageCoordinator: BaseCoordinator {
    
    let router: Router
    
    public var startFlow: ((WorkerMainPageCoordinatorDestination) -> ())!
    
    public init(router: Router) {
        self.router = router
        super.init()
    }
    
    public override func start() {
        let pageInfo = WorkerMainPageTab.allCases.map { tab in
            
            let navigationController = createNavForTab(tab: tab)
            
            return IdleTabBar.PageTabItemInfo(
                page: tab,
                navigationController: navigationController
            )
        }
        
        let tabBarModule = IdleTabBar(
            initialPage: WorkerMainPageTab.postBoard,
            info: pageInfo
        )
        
        router.replaceRootModuleTo(module: tabBarModule, animated: true) { [weak self] in
            self?.onFinish?()
        }
    }
}

// MARK: Setup tab pages
extension WorkerMainPageCoordinator {
    
    func createNavForTab(tab: WorkerMainPageTab) -> UINavigationController {
        
        let tabNavController = UINavigationController()
        tabNavController.setNavigationBarHidden(true, animated: false)
        
        startTabCoordinator(
            tab: tab,
            navigationController: tabNavController
        )
        
        return tabNavController
    }
    
    func startTabCoordinator(tab: WorkerMainPageTab, navigationController: UINavigationController) {
        
        switch tab {
        case .postBoard:
            presentPostBoardPage(controller: navigationController)
        case .preferredPost:
            presentStarredAndAppliedPostBoardPage(controller: navigationController)
        case .setting:
            presentSettingPage(controller: navigationController)
        }
    }
}

// MARK: TabPageFlow
public extension WorkerMainPageCoordinator {
    
    /// 포스트 보드
    func presentPostBoardPage(controller: UINavigationController) {
        
        let viewModel = MainPostBoardViewModel()
        viewModel.presentMyProfile = { [weak self] in
            self?.startFlow(.myProfilePage)
        }
        viewModel.presentPostDetailPage = { [weak self] id, type in
            self?.startFlow(.postDetailPage(id: id, type: type))
        }
        
        let viewController = MainPostBoardViewController()
        viewController.bind(viewModel: viewModel)
        
        router.push(
            module: viewController,
            to: controller,
            animated: false
        )
    }
    
    /// 좋아요/지원한 포스트 보드
    func presentStarredAndAppliedPostBoardPage(controller: UINavigationController) {
        
        let appliedPostViewModel = AppliedPostBoardViewModel()
        appliedPostViewModel.presentPostDetailPage = { [weak self] id, type in
            self?.startFlow(.postDetailPage(id: id, type: type))
        }
        
        let starredPostViewModel = StarredPostBoardViewModel()
        starredPostViewModel.presentPostDetailPage = { [weak self] id, type in
            self?.startFlow(.postDetailPage(id: id, type: type))
        }
        
        let viewController = StarredAndAppliedPostViewController()
        viewController.bind(
            appliedPostVM: appliedPostViewModel,
            starredPostVM: starredPostViewModel
        )
        
        router.push(
            module: viewController,
            to: controller,
            animated: false
        )
    }
    
    /// 세팅화면
    func presentSettingPage(controller: UINavigationController) {
        
        let viewModel = SettingPageViewModel()
        viewModel.presentDeregisterPage = { [weak self] in
            self?.startFlow(.accountDeregisterPage)
        }
        viewModel.presentMyProfilePage = { [weak self] in
            self?.startFlow(.myProfilePage)
        }
        viewModel.changeToAuthFlow = { [weak self] in
            self?.startFlow(.authFlow)
        }
        
        let viewController = SettingPageViewController()
        viewController.bind(viewModel: viewModel)
        
        router.push(
            module: viewController,
            to: controller,
            animated: false
        )
    }
}
