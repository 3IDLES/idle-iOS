//
//  SceneDelegate.swift
//
//
//  Created by 최준영 on 6/19/24.
//

import UIKit
import PresentationCore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    var rootCoordinator: RootCoordinator?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = scene as? UIWindowScene else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let rootNavigationController = UINavigationController()
        let injector = DependencyInjector.shared
        
        injector
            .assemble([
                DataAssembly(),
                DomainAssembly(),
                AuthAssembly(),
            ])
        
        rootCoordinator = RootCoordinator(
            dependency: .init(
                navigationController: rootNavigationController,
                injector: injector
            )
        )
        
        rootCoordinator?.start()
        
        window?.rootViewController = rootNavigationController
        window?.makeKeyAndVisible()
    }
}
