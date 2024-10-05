//
//  SceneDelegate.swift
//
//
//  Created by 최준영 on 6/19/24.
//

import UIKit
import CenterCetificatePageFeature
import BaseFeature
import Core

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    lazy var coordiantor = MakeCenterProfilePageCoordinator(router: router)
    
    let router = Router()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = scene as? UIWindowScene else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.makeKeyAndVisible()
        
        DependencyInjector.shared.assemble([
            DataAssembly(),
            DomainAssembly()
        ])

        
        coordiantor.start()
    }
}
