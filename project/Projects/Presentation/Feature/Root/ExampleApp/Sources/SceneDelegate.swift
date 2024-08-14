//
//  SceneDelegate.swift
//
//
//  Created by 최준영 on 6/19/24.
//

import UIKit
import RootFeature
import ConcreteUseCase
import ConcreteRepository
import NetworkDataSource

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    var coordinator: RegisterRecruitmentPostCoordinator!
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let store = TestStore()
        
        try! store.saveAuthToken(
            accessToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOm51bGwsInN1YiI6bnVsbCwiaXNzIjoiM2lkaW90cyIsImlhdCI6MTcyMzYyMTQ5MiwibmJmIjoxNzIzNjIxNDkyLCJleHAiOjE3MjM2MjIwOTIsInR5cGUiOiJBQ0NFU1NfVE9LRU4iLCJ1c2VySWQiOiIwMTkxNGZjMi04YTk4LTdhNDAtYWFmYS04OWM0MDhiZmEyOGMiLCJwaG9uZU51bWJlciI6IjAxMC00NDQ0LTUyMzIiLCJ1c2VyVHlwZSI6ImNlbnRlciJ9.WVD8-17nNTewK1EAARw_s-rxfs-6n1pZTyqCdvseIW8",
            refreshToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOm51bGwsInN1YiI6bnVsbCwiaXNzIjoiM2lkaW90cyIsImlhdCI6MTcyMzYyMDAzNywibmJmIjoxNzIzNjIwMDM3LCJleHAiOjE3MjQ4Mjk2MzcsInR5cGUiOiJSRUZSRVNIX1RPS0VOIiwidXNlcklkIjoiMDE5MTRmYzItOGE5OC03YTQwLWFhZmEtODljNDA4YmZhMjhjIiwidXNlclR5cGUiOiJjZW50ZXIifQ.hlnjMjEGDD11_XAR2QlfiT1awQoccvE04aqhkZUmWTc"
        )
        
        let nav = UINavigationController()
        nav.setNavigationBarHidden(true, animated: false)
        
        self.coordinator = RegisterRecruitmentPostCoordinator(
            dependency: .init(
                navigationController: nav,
                recruitmentPostUseCase: DefaultRecruitmentPostUseCase(
                    repository: DefaultRecruitmentPostRepository(store)
                )
            )
        )
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        
        coordinator.start()
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
