//
//  DeRegisterCoordinator.swift
//  RootFeature
//
//  Created by choijunios on 8/21/24.
//

import UIKit
import Entity
import PresentationCore
import UseCaseInterface

public protocol DeregisterCoordinatable: ParentCoordinator {
    
    /// 탈퇴과정이 끝났음을 알립니다.
    func flowFinished()
    
    /// 공통: 탈퇴 이유를 선택합니다.
    func showSelectReasonScreen()
    
    /// 센터관리자: 마지막으로 비밀번호를 입력합니다.
    func showFinalPasswordScreen(reasons: [DeregisterReasonVO])
    
    /// 요양보호사: 마지막으로 전화번호를 입력합니다.
    func showFinalPhoneAuthScreen(reasons: [DeregisterReasonVO])
    
    func coordinatorDidFinish()
}

public class DeRegisterCoordinator: DeregisterCoordinatable {
    
    public struct Dependency {
        let userType: UserType
        let authUseCase: AuthUseCase
        let navigationController: UINavigationController
        
        public init(userType: UserType, authUseCase: AuthUseCase, navigationController: UINavigationController) {
            self.userType = userType
            self.authUseCase = authUseCase
            self.navigationController = navigationController
        }
    }

    public var childCoordinators: [any Coordinator] = []
    
    public var navigationController: UINavigationController
    
    public var parent: ParentCoordinator?
    
    var viewControllerRef: UIViewController?
    let userType: UserType
    let authUseCase: AuthUseCase
    
    public init(dependency: Dependency) {
        self.userType = dependency.userType
        self.authUseCase = dependency.authUseCase
        self.navigationController = dependency.navigationController
    }
    
    public func start() {
        showSelectReasonScreen()
    }
    
    public func flowFinished() {
        
    }
    
    public func showSelectReasonScreen() {
        let coordinator: SelectReasonCoordinator = .init(
            dependency: .init(
                userType: userType,
                authUseCase: authUseCase,
                navigationController: navigationController
            )
        )
        addChildCoordinator(coordinator)
        coordinator.parent = self
        coordinator.start()
    }
    
    public func showFinalPasswordScreen(reasons: [Entity.DeregisterReasonVO]) {
    
        let coordinator = FinalPasswordAuhCoordinator(
            dependency: .init(
                authUseCase: authUseCase,
                reasons: reasons,
                navigationController: navigationController
            )
        )
        addChildCoordinator(coordinator)
        coordinator.parent = self
        coordinator.start()
    }
    
    public func showFinalPhoneAuthScreen(reasons: [Entity.DeregisterReasonVO]) {
        
    }
    
    public func coordinatorDidFinish() {
        popViewController()
        parent?.removeChildCoordinator(self)
    }
}
