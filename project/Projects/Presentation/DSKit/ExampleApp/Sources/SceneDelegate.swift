//
//  SceneDelegate.swift
//
//
//  Created by 최준영 on 6/19/24.
//

import UIKit
import DSKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = scene as? UIWindowScene else { return }
        
        window = UIWindow(windowScene: windowScene)
        let vc = IdleTabBar()
        vc.setViewControllers(info: [
            TabBarInfo(
                viewController: UINavigationController(rootViewController: {
                    let vc = UIViewController()
                    vc.view.backgroundColor = .blue
                    return vc
                }()),
                tabBarItem: .init(name: "홈")
            ),
            
            TabBarInfo(
                viewController: UINavigationController(rootViewController: {
                    let vc = UIViewController()
                    vc.view.backgroundColor = .yellow
                    return vc
                }()),
                tabBarItem: .init(name: "프로필")
            ),
            
            TabBarInfo(
                viewController: UINavigationController(rootViewController: {
                    let vc = UIViewController()
                    vc.view.backgroundColor = .red
                    return vc
                }()),
                tabBarItem: .init(name: "설정")
            ),
        ])
        
        vc.selectedIndex = 0
        
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
}
