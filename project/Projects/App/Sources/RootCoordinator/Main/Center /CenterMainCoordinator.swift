//
//  CenterMainCoordinator.swift
//  Idle-iOS
//
//  Created by choijunios on 7/25/24.
//

import UIKit
import DSKit
import PresentationCore
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
        
        let tabInfo = CenterMainScreen.allCases.map { tab in
            
            TabBarInfo(
                viewController: createNavForTab(tab: tab),
                tabBarItem: .init(
                    name: tab.name
                )
            )
        }
        
        let tabController = IdleTabBarProto()
        tabController.setViewControllers(info: tabInfo)
        tabController.selectedIndex = 0
        
        navigationController.pushViewController(tabController, animated: false)
    }
    
    // #1. Tab별 네비게이션 컨트롤러 생성
    func createNavForTab(tab: CenterMainScreen) -> UINavigationController {
        
        let tabNavController = UINavigationController()
        tabNavController.setNavigationBarHidden(true, animated: false)
        
        startTabCoordinator(
            tab: tab,
            navigationController: tabNavController
        )
        
        return tabNavController
    }
    // #2. 생성한 컨트롤러를 각 탭별 Coordinator에 전달
    func startTabCoordinator(tab: CenterMainScreen, navigationController: UINavigationController) {
        
        var coordinator: Coordinator!
        
        switch tab {
        case .recruitmentManage:
            coordinator = RecruitmentManagementCoordinator(
                dependency: .init(
                    parent: self,
                    navigationController: navigationController,
                    workerProfileUseCase: injector.resolve(WorkerProfileUseCase.self), 
                    recruitmentPostUseCase: injector.resolve(RecruitmentPostUseCase.self)
                )
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

// MARK: Center 탭의 구성요소들
enum CenterMainScreen: Int, CaseIterable {
    case recruitmentManage = 0
    case setting = 1
    
    var name: String {
        switch self {
        case .recruitmentManage:
            "채용"
        case .setting:
            "설정"
        }
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
