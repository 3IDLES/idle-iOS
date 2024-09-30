//
//  CenterMainCoordinator.swift
//  Idle-iOS
//
//  Created by choijunios on 7/25/24.
//

import UIKit
import DSKit
import PresentationCore
import CenterFeature
import RootFeature
import Domain
import Core

class CenterMainCoordinator: CenterMainCoordinatable {

    var childCoordinators: [Coordinator] = []
    
    weak var parent: ParentCoordinator?
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        
        let pageInfo = IdleCenterMainPage.allCases.map { page in
            
            let navigationController = createNavForTab(tab: page)
            
            return IdleTabBar.PageTabItemInfo(
                page: page,
                navigationController: navigationController
            )
        }
        
        let tabController = IdleTabBar(
            initialPage: IdleCenterMainPage.home,
            info: pageInfo
        )
        
        
        navigationController.pushViewController(tabController, animated: true)
    }
    
    // #1. Tab별 네비게이션 컨트롤러 생성
    func createNavForTab(tab: IdleCenterMainPage) -> UINavigationController {
        
        let tabNavController = UINavigationController()
        tabNavController.setNavigationBarHidden(true, animated: false)
        
        startTabCoordinator(
            tab: tab,
            navigationController: tabNavController
        )
        
        return tabNavController
    }
    // #2. 생성한 컨트롤러를 각 탭별 Coordinator에 전달
    func startTabCoordinator(tab: IdleCenterMainPage, navigationController: UINavigationController) {
        
        var coordinator: Coordinator!
        
        switch tab {
        case .home:
            coordinator = RecruitmentManagementCoordinator(navigationController: navigationController)
            
        case .setting:
            coordinator = CenterSettingCoordinator(navigationController: navigationController)
        }
        addChildCoordinator(coordinator)
        
        // 코디네이터들을 실행
        coordinator.start()
    }
    
}

// Test
extension CenterMainCoordinator {
    
    /// 센터 정보등록 창을 표시합니다.
    func centerProfileRegister() {
        
        let coordinator = CenterProfileRegisterCoordinator(navigationController: navigationController)
        addChildCoordinator(coordinator)
        coordinator.start()
    }
    
    /// 공고등록창을 표시합니다.
    func registerRecruitmentPost() {
        
        let coordinator = RegisterRecruitmentPostCoordinator(
            navigationController: navigationController
        )
        coordinator.parent = self
        addChildCoordinator(coordinator)
        coordinator.start()
    }
}
