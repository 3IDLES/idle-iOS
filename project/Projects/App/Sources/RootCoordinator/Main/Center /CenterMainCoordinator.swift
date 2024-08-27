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
import UseCaseInterface

class CenterMainCoordinator: CenterMainCoordinatable {
    
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
            coordinator = RecruitmentManagementCoordinator(
                dependency: .init(
                    parent: self,
                    injector: injector,
                    navigationController: navigationController
                )
            )
            
        case .setting:
            coordinator = CenterSettingCoordinator(
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

// Test
extension CenterMainCoordinator {
    
    /// 센터 정보등록 창을 표시합니다.
    func centerProfileRegister() {
        
        let coordinator = CenterProfileRegisterCoordinator(dependency: .init(
            navigationController: navigationController,
            injector: injector)
        )
        coordinator.parent = self
        addChildCoordinator(coordinator)
        coordinator.start()
    }
    
    /// 공고등록창을 표시합니다.
    func registerRecruitmentPost() {
        
        let coordinator = RegisterRecruitmentPostCoordinator(
            dependency: .init(
                navigationController: navigationController,
                recruitmentPostUseCase: injector.resolve(
                    RecruitmentPostUseCase.self
                )
            )
        )
        coordinator.parent = self
        addChildCoordinator(coordinator)
        coordinator.start()
    }
}
