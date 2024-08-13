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
        
        let tabInfo = WorkerMainScreen.allCases.map { tab in
            
            TabBarInfo(
                viewController: createNavForTab(tab: tab),
                tabBarItem: .init(
                    name: tab.name
                )
            )
        }
        
        let tabController = IdleTabBar()
        tabController.setViewControllers(info: tabInfo)
        tabController.selectedIndex = 0
        
        navigationController.pushViewController(tabController, animated: false)
    }
    
    // #1. Tab별 네비게이션 컨트롤러 생성
    func createNavForTab(tab: WorkerMainScreen) -> UINavigationController {
        
        let tabNavController = UINavigationController()
        tabNavController.setNavigationBarHidden(false, animated: false)
        
        startTabCoordinator(
            tab: tab,
            navigationController: tabNavController
        )
        
        return tabNavController
    }
    // #2. 생성한 컨트롤러를 각 탭별 Coordinator에 전달
    func startTabCoordinator(tab: WorkerMainScreen, navigationController: UINavigationController) {
        
        var coordinator: ChildCoordinator!
        
        switch tab {
        case .recruitmentBoard:
            coordinator = RecruitmentBoardCoordinator(
                navigationController: navigationController
            )
        case .applyManagement:
            coordinator = ApplyManagementCoordinator(
                navigationController: navigationController
            )
        case .setting:
            coordinator = SettingCoordinator(
                navigationController: navigationController
            )
        }
        addChildCoordinator(coordinator)
        
        // 코디네이터들을 실행
        coordinator.start()
    }
}

// MARK: Worker 탭의 구성요소들
enum WorkerMainScreen: Int, CaseIterable {
    case recruitmentBoard = 0
    case applyManagement = 1
    case setting = 2
    
    var name: String {
        switch self {
        case .recruitmentBoard:
            "채용"
        case .applyManagement:
            "공고관리"
        case .setting:
            "설정"
        }
    }
}
