//
//  SceneDelegate.swift
//
//
//  Created by 최준영 on 6/19/24.
//

import UIKit
import NotificationPageFeature
import PresentationCore
import UseCaseInterface
import ConcreteRepository
import Entity

import Swinject
import RxSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = scene as? UIWindowScene else { return }
        
        
        window = UIWindow(windowScene: windowScene)
        
        DependencyInjector.shared.assemble([
            TestAssembly()
        ])
        
        let viewModel = NotificationPageViewModel()
        
        window?.rootViewController = NotificationPageVC(viewModel: viewModel)
        window?.makeKeyAndVisible()
    }
}

public class TestAssembly: Assembly {
    
    public func assemble(container: Swinject.Container) {
        
        container.register(CacheRepository.self) { _ in
            DefaultCacheRepository()
        }
        
        container.register(NotificationPageUseCase.self) { _ in
            TestNotificationPageUseCase()
        }
    }
}

public class TestNotificationPageUseCase: NotificationPageUseCase {
    
    public init() { }
    
    public func getNotificationList() -> Single<Result<[NotificationCellInfo], DomainError>> {
        
        let task = Single<[NotificationCellInfo]>.create { observer in
            
            var mockData: [NotificationCellInfo] = []
            
            // 오늘
            mockData.append(
                contentsOf: (0..<5).map { _ in NotificationCellInfo.create(minute: -30) }
            )
            
            // 4일전
            mockData.append(
                contentsOf: (0..<5).map { _ in NotificationCellInfo.create(createdDay: -4) }
            )
            
            // 15일전
            mockData.append(
                contentsOf: (0..<5).map { _ in NotificationCellInfo.create(createdDay: -15) }
            )
            
            observer(.success(mockData))
            
            
            return Disposables.create { }
        }
        
        return convert(task: task)
    }
}
