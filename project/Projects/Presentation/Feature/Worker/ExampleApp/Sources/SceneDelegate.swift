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
import DataSource

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = scene as? UIWindowScene else { return }
        
        self.window = UIWindow(windowScene: windowScene)
        
        window?.rootViewController = WorkerSettingVC()
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
