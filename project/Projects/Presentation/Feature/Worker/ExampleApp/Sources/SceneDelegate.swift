//
//  SceneDelegate.swift
//
//
//  Created by 최준영 on 6/19/24.
//

import UIKit
import ConcreteUseCase
import ConcreteRepository
import WorkerFeature
import NetworkDataSource

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = scene as? UIWindowScene else { return }
        
        self.window = UIWindow(windowScene: windowScene)
        
        let store = TestStore()
        
        try! store.saveAuthToken(
            accessToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOm51bGwsInN1YiI6bnVsbCwiaXNzIjoiM2lkaW90cyIsImlhdCI6MTcyMzI5NzQyOCwibmJmIjoxNzIzMjk3NDI4LCJleHAiOjE3MjMyOTgwMjgsInR5cGUiOiJBQ0NFU1NfVE9LRU4iLCJ1c2VySWQiOiIwMTkxM2M4Ny1mMjMxLTdmMDctYTNjYS1jYTJhNjk4OTExZWQiLCJwaG9uZU51bWJlciI6IjAxMC0zMzI2LTU2NzgiLCJ1c2VyVHlwZSI6ImNhcmVyIn0.R_obT8lFGxf2jeDhrpC0aLntwDslI-NYoEbyEZLwhZ0",
            refreshToken: ""
        )
        
        let useCase = DefaultWorkerProfileUseCase(
            repository: DefaultUserProfileRepository(store)
        )
        
        let vm = WorkerMyProfileViewModel(
            coordinator: nil,
            workerProfileUseCase: useCase
        )
        
        let vc = WorkerProfileViewController()
        
        vc.bind(vm)
        
        let nav = UINavigationController(rootViewController: vc)
        nav.setNavigationBarHidden(true, animated: false)
        
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
    }
}


class TestStore: KeyValueStore {
    func save(key: String, value: String) throws {
        UserDefaults.standard.setValue(value, forKey: key)
    }
    
    func get(key: String) -> String? {
        UserDefaults.standard.string(forKey: key)
    }
    
    func delete(key: String) throws {
        
    }
    
    func removeAll() throws {
        
    }
    
}
