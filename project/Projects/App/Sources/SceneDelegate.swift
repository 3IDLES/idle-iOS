//
//  SceneDelegate.swift
//
//
//  Created by 최준영 on 6/19/24.
//

import UIKit
import PresentationCore
import Core

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    // RootCoordinator
    var rootCoordinator: RootCoordinator!
    
    // FCMService
    var fcmService: FCMService!
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = scene as? UIWindowScene else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let rootNavigationController = UINavigationController()
        let injector = DependencyInjector.shared
        
        injector
            .assemble([
                LoggerAssembly(),
                DataAssembly(),
                DomainAssembly(),
            ])
        
        // FCMService
        fcmService = FCMService()
        
        // RootCoordinator
        rootCoordinator = RootCoordinator(navigationController: rootNavigationController)
        
        rootCoordinator?.start()
        
        window?.rootViewController = rootNavigationController
        window?.makeKeyAndVisible()
    }
}
