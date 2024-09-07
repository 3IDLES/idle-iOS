//
//  RootCoordinator+Extension.swift
//  Idle-iOS
//
//  Created by choijunios on 6/30/24.
//

import Foundation
import AuthFeature
import PresentationCore

extension RootCoordinator: RootCoorinatable {
    
    /// 로그인및 회원가입을 실행합니다.
    func auth() {
        
        let coordinator = AuthCoordinator(
            dependency: .init(
                navigationController: navigationController,
                injector: injector
            )
        )
        
        coordinator.parent = self
        
        addChildCoordinator(coordinator)
        
        coordinator.start()
    }
    
    func centerAuth() {
        
    }
    
    /// 요양보호사 메인화면을 실행합니다.
    func workerMain() {
        
        let coordinator = WorkerMainCoordinator(
            dependency: .init(
                navigationController: navigationController,
                injector: injector
            )
        )
        coordinator.parent = self
        
        addChildCoordinator(coordinator)
        
        coordinator.start()
    }
    
    /// 센터 메인화면을 시작합니다.
    func centerMain() {
        
        let coordinator = CenterMainCoordinator(
            dependency: .init(
                navigationController: navigationController,
                injector: injector
            )
        )
        coordinator.parent = self
        
        addChildCoordinator(coordinator)
        
        coordinator.start()
    }
    
    /// 루트 VC까지 모든 네비게이션을 제거합니다, 이후 코디네이터도 제거합니다.
    func popToRoot() {
        navigationController.popToRootViewController(animated: true)
        childCoordinators.removeAll()
    }
}
