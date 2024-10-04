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
    case postDetailPage(id: String)
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
            presentLikedAndAppliedPostBoardPage(controller: navigationController)
        case .setting:
            presentSettingPage(controller: navigationController)
        }
    }
}

// MARK: TabPageFlow
public extension WorkerMainPageCoordinator {
    
    /// 포스트 보드
    func presentPostBoardPage(controller: UINavigationController) {
        
        
    }
    
    /// 좋아요/지원한 포스트 보드
    func presentLikedAndAppliedPostBoardPage(controller: UINavigationController) {
        
        
    }
    
    /// 세팅화면
    func presentSettingPage(controller: UINavigationController) {
        
        
    }
}
