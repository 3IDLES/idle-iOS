//
//  SceneDelegate.swift
//
//
//  Created by 최준영 on 6/19/24.
//

import UIKit

import AuthFeature
import BaseFeature
import Testing
import Core

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    var authCoordinator: AuthCoordinator?
    var centerAccountRegisterCoordinator: CenterAccountRegisterCoordinator?
    var centerLogInCoordinator: CenterLogInCoordinator?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = scene as? UIWindowScene else { return }
        
        DependencyInjector.shared.assemble(MockAssemblies)
        DependencyInjector.shared.register(CenterRegisterLogger.self, CenterAuthLogger())
        
        authCoordinator = .init()
        
        authCoordinator?.startFlow = { [weak self] desination in
            
            switch desination {
            case .centerRegisterPage:
                
                let coordinator = CenterAccountRegisterCoordinator()
                self?.centerAccountRegisterCoordinator = coordinator
                coordinator.start()
                
            case .loginPage:
                let coordinator = CenterLogInCoordinator()
                
                coordinator.startFlow = { desination in
                    switch desination {
                    default:
                        // 센터 메인페이지로 이동
                        return
                    }
                }
                
                self?.centerLogInCoordinator = coordinator
                coordinator.start()
            default:
                // 테스트시 추가가능
                return
            }
        }

        window = UIWindow(windowScene: windowScene)
        window?.makeKeyAndVisible()
        
        authCoordinator?.start()
    }
}

class CenterAuthLogger: CenterRegisterLogger {
    
    func logCenterRegisterStep(stepName: String, stepIndex: Int) { }
    
    func startCenterRegister() { }
    
    func logCenterRegisterDuration() { }
}
