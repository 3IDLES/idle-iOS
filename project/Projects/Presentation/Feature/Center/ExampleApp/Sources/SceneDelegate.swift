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
            accessToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOm51bGwsInN1YiI6bnVsbCwiaXNzIjoiM2lkaW90cyIsImlhdCI6MTcyMzYyMDAzNywibmJmIjoxNzIzNjIwMDM3LCJleHAiOjE3MjM2MjA2MzcsInR5cGUiOiJBQ0NFU1NfVE9LRU4iLCJ1c2VySWQiOiIwMTkxNGZjMi04YTk4LTdhNDAtYWFmYS04OWM0MDhiZmEyOGMiLCJwaG9uZU51bWJlciI6IjAxMC00NDQ0LTUyMzIiLCJ1c2VyVHlwZSI6ImNlbnRlciJ9.cYk9E0EJwMpX3wxhQq6R5nMKaVGj2yA7csDybB-Jn8o",
            refreshToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOm51bGwsInN1YiI6bnVsbCwiaXNzIjoiM2lkaW90cyIsImlhdCI6MTcyMjIyNzcxMywibmJmIjoxNzIyMjI3NzEzLCJleHAiOjE3MjM0MzczMTMsInR5cGUiOiJSRUZSRVNIX1RPS0VOIiwidXNlcklkIjoiMDE5MGZjYzUtNThiNS03ZTlmLWExNzUtYWQ1MDI2YzMyODNhIiwidXNlclR5cGUiOiJjZW50ZXIifQ.EtV-qojoAl-H7VVm-Dr2tYf6Hkbx3OdwbsxduAOFf6I"
        )
        
        let useCase = DefaultCenterProfileUseCase(
            repository: DefaultUserProfileRepository(store)
        )
        
        let navigationController = UINavigationController()
        navigationController.setNavigationBarHidden(true, animated: false)
        
        
        
//        let coordinator = RegisterRecruitmentCoordinator(
//            viewModel: vm,
//            navigationController: navigationController
//        )
//        
//        let vm = RegisterRecruitmentPostVM(
//            registerRecruitmentPostCoordinator: coordinator, recruitmentPostUseCase: DefaultRecruitmentPostUseCase(
//                repository: DefaultRecruitmentPostRepository()
//            )
//        )
//        
        let vc = CenterSettingVC()
        let vm = CenterSettingVM(
            coordinator: nil,
            settingUseCase: DefaultSettingUseCase(repository: DefaultAuthRepository()),
            centerProfileUseCase: DefaultCenterProfileUseCase(
                repository: DefaultUserProfileRepository()
            )
        )
        
        vc.bind(viewModel: vm)
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
        
//        coordinator.start()
    }
}
