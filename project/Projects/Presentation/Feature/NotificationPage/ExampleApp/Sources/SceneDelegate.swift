//
//  SceneDelegate.swift
//
//
//  Created by 최준영 on 6/19/24.
//

import UIKit

import NotificationPageFeature
import BaseFeature
import PresentationCore
import Domain
import Repository
import Core

import Testing

import Swinject
import RxSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    var router: RouterProtocol?
    
    var coordinator: NotificationPageCoordinator?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = scene as? UIWindowScene else { return }
        
        DependencyInjector.shared.assemble(MockAssemblies)
        
        self.router = DependencyInjector.shared.resolve(RouterProtocol.self)
        
        coordinator = .init()
        
        window = UIWindow(windowScene: windowScene)
        window?.makeKeyAndVisible()
        
        router?.setRootModuleTo(module: UIViewController(), popCompletion: nil)
        coordinator?.start()
    }
}

public class TestAssembly: Assembly {
    
    public func assemble(container: Swinject.Container) {
        
        container.register(CacheRepository.self) { _ in
            DefaultCacheRepository()
        }
    }
}
