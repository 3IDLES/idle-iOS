//
//  WorkerMainCoordinator.swift
//  Idle-iOS
//
//  Created by choijunios on 7/25/24.
//

import UIKit
import DSKit
import PresentationCore
import RootFeature

class WorkerMainCoordinator: ParentCoordinator {
    
    struct Dependency {
        let navigationController: UINavigationController
        let injector: Injector
    }
    
    var childCoordinators: [Coordinator] = []
    
    var parent: ParentCoordinator?
    
    var navigationController: UINavigationController
    let injector: Injector
    
    init(dependency: Dependency) {
        self.navigationController = dependency.navigationController
        self.injector = dependency.injector
    }
    
    func start() {
        
        let pageInfo = IdleWorkerMainPage.allCases.map { page in
            
            let navigationController = createNavForTab(page: page)
            
            return IdleTabBar.PageTabItemInfo(
                page: page,
                navigationController: navigationController
            )
        }
        
        let tabController = IdleTabBar(
            initialPage: IdleWorkerMainPage.home,
            info: pageInfo
        )
        
        
        navigationController.pushViewController(tabController, animated: false)
    }
    
    // #1. Tab별 네비게이션 컨트롤러 생성
    func createNavForTab(page: IdleWorkerMainPage) -> UINavigationController {
        
        let tabNavController = UINavigationController()
        tabNavController.setNavigationBarHidden(false, animated: false)
        
        startTabCoordinator(
            page: page,
            navigationController: tabNavController
        )
        
        return tabNavController
    }
    // #2. 생성한 컨트롤러를 각 탭별 Coordinator에 전달
    func startTabCoordinator(page: IdleWorkerMainPage, navigationController: UINavigationController) {
        
        var coordinator: ChildCoordinator!
        
        switch page {
        case .home:
            coordinator = RecruitmentBoardCoordinator(
                navigationController: navigationController
            )
        case .preferredPost:
            coordinator = ApplyManagementCoordinator(
                navigationController: navigationController
            )
        case .setting:
            coordinator = RecruitmentBoardCoordinator(
                navigationController: navigationController
            )
        }
        
        addChildCoordinator(coordinator)
        
        // 코디네이터들을 실행
        coordinator.start()
    }
}
