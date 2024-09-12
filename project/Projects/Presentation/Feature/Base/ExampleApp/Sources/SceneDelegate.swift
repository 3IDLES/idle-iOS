//
//  SceneDelegate.swift
//
//
//  Created by 최준영 on 6/19/24.
//

import UIKit
import BaseFeature

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let vm = BaseViewModel()
        let vc = ViewController()
        vc.bind(viewModel: vm)
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = vc
        
        window?.makeKeyAndVisible()
    }
}
