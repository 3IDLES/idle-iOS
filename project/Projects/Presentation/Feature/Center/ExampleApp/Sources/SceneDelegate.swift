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
            accessToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOm51bGwsInN1YiI6bnVsbCwiaXNzIjoiM2lkaW90cyIsImlhdCI6MTcyMjIyNzcxMywibmJmIjoxNzIyMjI3NzEzLCJleHAiOjE3MjIyMjgzMTMsInR5cGUiOiJBQ0NFU1NfVE9LRU4iLCJ1c2VySWQiOiIwMTkwZmNjNS01OGI1LTdlOWYtYTE3NS1hZDUwMjZjMzI4M2EiLCJwaG9uZU51bWJlciI6IjAxMC00NDQ0LTUyMzIiLCJ1c2VyVHlwZSI6ImNlbnRlciJ9.gJXEtDruIRqYM9R6aszejnIDOm8VP6ROnrNqESIdssE",
            refreshToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOm51bGwsInN1YiI6bnVsbCwiaXNzIjoiM2lkaW90cyIsImlhdCI6MTcyMjIyNzcxMywibmJmIjoxNzIyMjI3NzEzLCJleHAiOjE3MjM0MzczMTMsInR5cGUiOiJSRUZSRVNIX1RPS0VOIiwidXNlcklkIjoiMDE5MGZjYzUtNThiNS03ZTlmLWExNzUtYWQ1MDI2YzMyODNhIiwidXNlclR5cGUiOiJjZW50ZXIifQ.EtV-qojoAl-H7VVm-Dr2tYf6Hkbx3OdwbsxduAOFf6I"
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
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
    }
}
