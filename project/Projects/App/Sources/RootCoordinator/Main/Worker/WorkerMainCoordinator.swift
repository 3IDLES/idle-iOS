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
import Domain

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
        
        
        navigationController.pushViewController(tabController, animated: true)
    }
    
    // #1. Tab별 네비게이션 컨트롤러 생성
    func createNavForTab(page: IdleWorkerMainPage) -> UINavigationController {
        
        let tabNavController = UINavigationController()
        tabNavController.setNavigationBarHidden(true, animated: false)
        
        startTabCoordinator(
            page: page,
            navigationController: tabNavController
        )
        
        return tabNavController
    }
    // #2. 생성한 컨트롤러를 각 탭별 Coordinator에 전달
    func startTabCoordinator(page: IdleWorkerMainPage, navigationController: UINavigationController) {
        
        var coordinator: Coordinator!
        
        switch page {
        case .home:
            coordinator = WorkerRecruitmentBoardCoordinator(
                depedency: .init(
                    parent: self,
                    injector: injector,
                    navigationController: navigationController
                )
            )
        case .preferredPost:
            coordinator = AppliedAndLikedBoardCoordinator(
                depedency: .init(
                    parent: self,
                    injector: injector,
                    navigationController: navigationController
                )
            )
        case .setting:
            coordinator = WorkerSettingCoordinaator(
                dependency: .init(
                    parent: self,
                    injector: injector,
                    navigationController: navigationController
                )
            )
        }
        
        addChildCoordinator(coordinator)
        
        // 코디네이터들을 실행
        coordinator.start()
    }
}
