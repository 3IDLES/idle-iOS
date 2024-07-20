//
//  SceneDelegate.swift
//
//
//  Created by 최준영 on 6/19/24.
//

import UIKit
import CenterFeature
import ConcreteUseCase
import ConcreteRepository

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = scene as? UIWindowScene else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let viewModel = CenterProfileViewModel(
            useCase: DefaultCenterProfileUseCase(
                repository: DefaultUserProfileRepository()
            )
        )
        
        let viewController = CenterProfileViewController()
        
        viewController.bind(viewModel: viewModel)
        
        self.window?.rootViewController = viewController
        self.window?.makeKeyAndVisible()
        
    }
}
