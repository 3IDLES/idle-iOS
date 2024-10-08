//
//  SceneDelegate.swift
//
//
//  Created by 최준영 on 6/19/24.
//

import UIKit
import PresentationCore
import Core
import RootFeature
import BaseFeature

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    // RootCoordinator
    let router: Router = .init()
    
    lazy var appCoordinator: AppCoordinator = {
        let coodinator = AppCoordinator(router: router)
        return coodinator
    }()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = scene as? UIWindowScene else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.makeKeyAndVisible()
        
        let injector = DependencyInjector.shared
        
        injector
            .assemble([
                LoggerAssembly(),
                DataAssembly(),
                DomainAssembly(),
            ])
    
        // Start AppCoodinator
        appCoordinator.start()
    }
}
