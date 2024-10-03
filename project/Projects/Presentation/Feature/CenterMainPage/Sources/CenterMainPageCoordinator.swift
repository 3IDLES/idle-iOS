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
}

public class CenterMainPageCoordinator: BaseCoordinator {
    
    let router: Router
    
    public var startFlow: ((CenterMainPageCoordinatorDestination) -> ())!
    
    public init(router: Router) {
        self.router = router
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
        
        router.replaceRootModuleTo(module: tabBarModule, animated: true)
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
            let coordinator = CenterPostBoardPageCoordinator(
                router: router,
                tabController: navigationController
            )
            
            coordinator.startFLow = { [weak self] destination in
                
                guard let self else { return }
                
                switch destination {
                case .postApplicantPage(let postId):
                    presentPostApplicantPage(postId: postId)
                case .postEditPage(let postId):
                    presentPostEditPage(postId: postId)
                case .postDetailPage(let postId, let postState):
                    presentPostDetailPage(postId: postId, postState: postState)
                case .registerPostPage:
                    presentRegisterPostPage()
                }
            }
            
            addChild(coordinator)
            coordinator.start()
            
        case .setting:
            return
        }
    }
}

// MARK: SubFlow
extension CenterMainPageCoordinator {
    
    public func presentPostApplicantPage(postId: String) {
        let coordinator = PostApplicantPageCoordinator(
            router: router,
            postId: postId
        )
        
        coordinator.startFlow = { [weak self] destination in
            switch destination {
            case .applicantDetail(let id):
                self?.startFlow(.workerProfilePage(id: id))
            }
        }
        
        addChild(coordinator)
        coordinator.start()
    }
    
    public func presentPostEditPage(postId: String) {
        
    }
    
    public func presentPostDetailPage(postId: String, postState: PostState) {
        
    }
    
    public func presentRegisterPostPage() {
        
        
    }
}
