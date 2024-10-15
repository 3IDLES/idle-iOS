//
//  AppCoordinator.swift
//  RootFeature
//
//  Created by choijunios on 10/2/24.
//

import Foundation
import BaseFeature
import SplashFeature
import AuthFeature
import CenterMainPageFeature
import WorkerMainPageFeature
import CenterCetificatePageFeature
import AccountDeregisterFeature
import PostDetailForWorkerFeature
import UserProfileFeature
import Domain
import Core


import RxSwift

public class AppCoordinator: BaseCoordinator {
    
    // Injected
    @Injected var router: RouterProtocol
    @Injected var notificationHelper: RemoteNotificationHelper
    
    let disposeBag: DisposeBag = .init()
    
    public init() { }
    
    public override func start() {
        
        runSplashFlow()
    }
}

extension AppCoordinator {
    
    func executeChild(_ coordinator: Coordinator) {
        coordinator.onFinish = { [weak self, weak coordinator] in
            if let coordinator {
                self?.removeChild(coordinator)
            }
        }
        addChild(coordinator)
        coordinator.start()
    }
    
    /// SplashFlow를 시작합니다.
    @discardableResult
    func runSplashFlow() -> SplashCoordinator {
        
        let coordinator = SplashCoordinator()
        coordinator.delegate = self
        
        coordinator.startFlow = { [weak self] destination in
            
            guard let self else { return }
            
            switch destination {
            case .authPage:
                runAuthFlow()
            case .mainPage(let userType):
                
                switch userType {
                case .center:
                    runCenterMainPageFlow()
                case .worker:
                    runWorkerMainPageFlow()
                }
                
            case .centerCertificatePage:
                runCenterCertificateFlow()
            case .centerMakeProfilePage:
                runMakeCenterProfileFlow()
            }
        }
        
        executeChild(coordinator)
        
        return coordinator
    }
    
    
    /// AuthFlow를 시작합니다.
    @discardableResult
    func runAuthFlow() -> AuthCoordinator {
        let coordinator = AuthCoordinator()
        
        coordinator.startFlow = { [weak self] destination in
            
            guard let self else { return }
            
            switch destination {
            case .centerRegisterPage:
                centerAccountRegisterFlow()
            case .workerRegisterPage:
                workerAccountRegisterFlow()
            case .loginPage:
                centerLoginFlow()
            }
        }
        
        executeChild(coordinator)
        
        return coordinator
    }
    
    
    /// CenterCetrificateFlow를 시작합니다.
    @discardableResult
    func runCenterCertificateFlow() -> WaitCertificatePageCoordinator {
        let coordinator = WaitCertificatePageCoordinator()
        coordinator.startFlow = { [weak self] destination in
            guard let self else { return }
            switch destination {
            case .authFlow:
                runAuthFlow()
            case .makeProfileFlow:
                runMakeCenterProfileFlow()
            }
        }
        
        executeChild(coordinator)
        
        return coordinator
    }
    
    
    /// CenterMainFlow를 시작합니다.
    @discardableResult
    func runCenterMainPageFlow() -> CenterMainPageCoordinator {
        let coordinator = CenterMainPageCoordinator()
        coordinator.startFlow = { [weak self] destination in
            guard let self else { return }
            switch destination {
            case .workerProfilePage(let workerId):
                workerProfileFlow(id: workerId)
            case .createPostPage:
                createPostFlow()
            case .myCenterProfilePage:
                centerProfileFlow(mode: .myProfile)
            case .authFlow:
                runAuthFlow()
            case .accountDeregisterPage:
                accountDeregister(userType: .center)
            }
        }
        
        executeChild(coordinator)
        
        return coordinator
    }
    
    
    /// WorkerMainFlow를 시작합니다.
    @discardableResult
    func runWorkerMainPageFlow() -> WorkerMainPageCoordinator {
        let coordinator = WorkerMainPageCoordinator()
        coordinator.startFlow = { [weak self] destination in
            guard let self else { return }
            switch destination {
            case .accountDeregisterPage:
                accountDeregister(userType: .worker)
            case .authFlow:
                runAuthFlow()
            case .myProfilePage:
                workerMyProfileFlow()
            case .postDetailPage(let info):
                postDetailForWorkerFlow(postInfo: info)
            }
        }
        
        executeChild(coordinator)
        
        return coordinator
    }
    
    
    /// CenterMakeProfileFlow를 시작합니다.
    func runMakeCenterProfileFlow() {
        let coordinator = MakeCenterProfilePageCoordinator()
        coordinator.startFlow = { [weak self] destination in
            switch destination {
            case .authFlow:
                self?.runAuthFlow()
            case .centerMainPageFlow:
                self?.runCenterMainPageFlow()
            }
        }
        
        executeChild(coordinator)
    }
}

// MARK: AuthFlow
extension AppCoordinator {
    
    /// 센터관리자 계정가입을 시작합니다.
    @discardableResult
    func centerAccountRegisterFlow() -> CenterAccountRegisterCoordinator {
        
        let coordinator = CenterAccountRegisterCoordinator()
        coordinator.startFlow = { [weak self] destination in
            
            guard let self else { return }
            
            switch destination {
            case .centerMainPage:
                runCenterMainPageFlow()
            }
        }
        
        executeChild(coordinator)
        
        return coordinator
    }
    
    /// 요양보호사 계정가입을 시작합니다.
    @discardableResult
    func workerAccountRegisterFlow() -> WorkerAccountRegisterCoordinator {
        
        let coordinator = WorkerAccountRegisterCoordinator()
        coordinator.startFlow = { [weak self] destination in
            
            switch destination {
            case .workerMainPage:
                self?.runWorkerMainPageFlow()
            }
        }
        
        executeChild(coordinator)
        
        return coordinator
    }
    
    /// 센터관리자 회원가입을 시작합니다.
    @discardableResult
    func centerLoginFlow() -> CenterLogInCoordinator {
        
        let coordinator = CenterLogInCoordinator()
        coordinator.startFlow = { [weak self] destination in
            switch destination {
            case .centerMainPage:
                self?.runCenterMainPageFlow()
            }
        }
        
        executeChild(coordinator)
        
        return coordinator
    }
    
}

// MARK: Post
extension AppCoordinator {
    
    @discardableResult
    func createPostFlow() -> CreatePostCoordinator {
        
        let coordinator = CreatePostCoordinator()
        
        executeChild(coordinator)
        
        return coordinator
    }
    
    @discardableResult
    func postDetailForWorkerFlow(postInfo: RecruitmentPostInfo) -> PostDetailForWorkerCoodinator {
        let coordinator = PostDetailForWorkerCoodinator(postInfo: postInfo)
        coordinator.startFlow = { [weak self] destination in
            switch destination {
            case .centerProfile(let mode):
                self?.centerProfileFlow(mode: mode)
            }
        }
        
        executeChild(coordinator)
        return coordinator
    }
}

// MARK: User profile
extension AppCoordinator {
    
    func workerProfileFlow(id: String) {
        let coordinator = WorkerProfileCoordinator(id: id)
        executeChild(coordinator)
    }
    
    func workerMyProfileFlow() {
        let coordinator = WorkerMyProfileCoordinator()
        executeChild(coordinator)
    }
    
    func centerProfileFlow(mode: ProfileMode) {
        let coordinator = CenterProfileCoordinator(mode: mode)
        executeChild(coordinator)
    }
}

// MARK: Account Deregister
extension AppCoordinator {
    
    @discardableResult
     func accountDeregister(userType: UserType) -> AccountDeregisterCoordinator {
         let coordinator = AccountDeregisterCoordinator(userType: userType)
         coordinator.startFlow = { [weak self] destination in
             switch destination {
             case .accountAuthFlow:
                 self?.runAuthFlow()
             }
         }
         
         executeChild(coordinator)
         return coordinator
     }
}


// MARK: watch push notifications
extension AppCoordinator: SplashCoordinatorDelegate {
    
    public func splashCoordinator(satisfiedAllCondition: Bool) {
        
        if !satisfiedAllCondition { return }
        
        notificationHelper
            .deeplinks
            .observe(on: MainScheduler.instance)
            .subscribe (onNext: { [weak self] bundle in
                
                guard let self else { return }
                
                var currentCoordinator: Coordinator? = self
                
                bundle.deeplinks
                    .forEach { deeplink in
                        currentCoordinator = deeplink.execute(
                            with: currentCoordinator!,
                            userInfo: bundle.userInfo
                        )
                    }
            })
            .disposed(by: disposeBag)
    }
}
