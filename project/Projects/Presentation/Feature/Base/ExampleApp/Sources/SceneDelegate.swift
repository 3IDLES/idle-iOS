//
//  SceneDelegate.swift
//
//
//  Created by 최준영 on 6/19/24.
//

import UIKit
import BaseFeature

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    let navigationController: UINavigationController = .init()
    
    var window: UIWindow?
    
    var router: Router!
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = scene as? UIWindowScene else { return }
    
        window = UIWindow(windowScene: windowScene)
        window?.makeKeyAndVisible()
        
        var rootVC: UIViewController!
        
        navigationController.setNavigationBarHidden(true, animated: false)
        self.router = Router()
        router.setRootModuleTo(module: .createRand(), popCompletion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            
            rootVC = .createRand()
            
            self.router.replaceRootModuleTo(module: rootVC, animated: true) {
                
                print("루트 변경 완료")
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+4) {
            
            self.router.push(
                module: .createRand(),
                animated: true) {
                    print("첫번째 푸쉬 팝")
                }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+5) {
            
            self.router.push(
                module: .createRand(),
                animated: true) {
                    print("두번째 푸쉬 팝")
                }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+6) {
            
            self.router.popModule(animated: true)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+7) {
            
            self.router.popModule(animated: true)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+8) {
            
            self.router.push(
                module: .createRand(),
                animated: true)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+9) {
            
            self.router.push(
                module: .createRand(),
                animated: true)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+10) {
            
            self.router.popTo(module: rootVC, animated: true)
        }
    }
}

extension UIViewController {
    
    static func createRand() -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.randomColor()
        return vc
    }
}

extension UIColor {
    static func randomColor() -> UIColor {
        return UIColor(
            red: CGFloat.random(in: 0...1),
            green: CGFloat.random(in: 0...1),
            blue: CGFloat.random(in: 0...1),
            alpha: 1.0
        )
    }
}
