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
        
        let store = TestStore()
        
        try! store.saveAuthToken(
            accessToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOm51bGwsInN1YiI6bnVsbCwiaXNzIjoiM2lkaW90cyIsImlhdCI6MTcyMjIyNDUzNywibmJmIjoxNzIyMjI0NTM3LCJleHAiOjE3MjIyMjUxMzcsInR5cGUiOiJBQ0NFU1NfVE9LRU4iLCJ1c2VySWQiOiIwMTkwZjI2NS0yYmVkLTc1MTEtYjljNy1hZjEwOTNhZTUzZmIiLCJwaG9uZU51bWJlciI6IjAxMC00NDQ0LTUyMzIiLCJ1c2VyVHlwZSI6ImNlbnRlciJ9.VIJ9OG6VubPNYOhSfTRt1rG_mbq6ttVNHfT1-cnjZsc",
            refreshToken: ""
        )
        
        let useCase = DefaultCenterProfileUseCase(
            repository: DefaultUserProfileRepository(store)
        )
        
        let navigationController = UINavigationController()
        navigationController.setNavigationBarHidden(true, animated: false)
        
        let coordinator = RegisterCenterInfoCoordinator(
            profileUseCase: useCase,
            navigationController: navigationController
        )
        
        let vc = CenterProfileViewController()
        vc.bind(viewModel: CenterProfileViewModel(
            useCase: useCase
        ))
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
        
        
    }
}
