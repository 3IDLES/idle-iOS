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
            accessToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOm51bGwsInN1YiI6bnVsbCwiaXNzIjoiM2lkaW90cyIsImlhdCI6MTcyMTUzMDYwMCwibmJmIjoxNzIxNTMwNjAwLCJleHAiOjE3MjE1MzEyMDAsInR5cGUiOiJBQ0NFU1NfVE9LRU4iLCJ1c2VySWQiOiIwMTkwZDMzOC0zZjg0LTc3M2MtOTZhYy01MzZlODg2ZjBkMjUiLCJwaG9uZU51bWJlciI6IjAxMC00NDQ0LTUyMzIifQ.dA9TrFJFDL715ram0uaShCjqRPI8t8iZ39ZJn7oHu6E",
            refreshToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOm51bGwsInN1YiI6bnVsbCwiaXNzIjoiM2lkaW90cyIsImlhdCI6MTcyMTQ4OTczMCwibmJmIjoxNzIxNDg5NzMwLCJleHAiOjE3MjI2OTkzMzAsInR5cGUiOiJSRUZSRVNIX1RPS0VOIiwidXNlcklkIjoiMDE5MGNmNDgtM2RjNi03ZWVkLTk4OGUtYTA5N2EwZDEwYjMzIn0.Hx4t09U3ra5RbYvwjl3flQccw6-hBMWUxY6zI_eVpiQ"
        )
        
        let useCase = DefaultCenterProfileUseCase(
            repository: DefaultUserProfileRepository(store)
        )
        
        let viewModel = CenterProfileViewModel(
            useCase: useCase
        )
        
        let vc = CenterProfileViewController()
        
        vc.bind(viewModel: viewModel)
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
}
