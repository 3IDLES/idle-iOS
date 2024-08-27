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
            accessToken: "",
            refreshToken: ""
        )
        
//        let useCase = DefaultCenterProfileUseCase(
//            repository: DefaultUserProfileRepository(store)
//        )
        
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
//        let vc = CenterSettingVC()
//        let vm = CenterSettingVM(
//            coordinator: nil,
//            settingUseCase: DefaultSettingUseCase(repository: DefaultAuthRepository()),
//            centerProfileUseCase: DefaultCenterProfileUseCase(
//                repository: DefaultUserProfileRepository()
//            )
//        )
//        
//        vc.bind(viewModel: vm)
//        
//        window = UIWindow(windowScene: windowScene)
//        window?.rootViewController = vc
//        window?.makeKeyAndVisible()
        
//        coordinator.start()
    }
}
