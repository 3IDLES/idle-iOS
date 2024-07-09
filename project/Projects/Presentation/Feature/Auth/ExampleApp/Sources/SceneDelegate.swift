//
//  SceneDelegate.swift
//
//
//  Created by 최준영 on 6/19/24.
//

import UIKit
import AuthFeature
import ConcreteUseCase
import ConcreteRepository

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = scene as? UIWindowScene else { return }
        
        
        window = UIWindow(windowScene: windowScene)
        
        let viewModel = CenterRegisterViewModel(
            useCase: DefaultCenterRegisterUseCase(
                repository: DefaultCenterRegisterRepository()
            )
        )
        
        window?.rootViewController = EnterNameViewController(
            viewModel: viewModel
        )
        window?.makeKeyAndVisible()
    }
}
