//
//  SceneDelegate.swift
//
//
//  Created by 최준영 on 6/19/24.
//

import UIKit
import AuthFeature
import BaseFeature
import PresentationCore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let renderObject: AnonymousCompleteVCRenderObject = .init(
            titleText: "센터관리자 로그인을\n완료했어요!",
            descriptionText: "로그인 정보는 마지막 접속일부터\n180일간 유지될 예정이에요.",
            completeButtonText: "시작하기") { }
        
        let vc = AnonymousCompleteVC()
        vc.applyRO(renderObject)
        
        window = UIWindow(windowScene: windowScene)
        
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
}
