//
//  WorkerMainPageDeepLink.swift
//  Root
//
//  Created by choijunios on 11/13/24.
//

import Foundation
import BaseFeature

class WorkerMainPageDeepLink: DeeplinkExecutable {
    
    var component: DeepLinkPathComponent = .centerMainPage
    
    var children: [DeeplinkExecutable] = [
        PostApplicantDeeplink()
    ]
    
    var isDestination: Bool = false
    
    init() { }
    
    func execute(with coordinator: any BaseFeature.Coordinator, userInfo: [AnyHashable : Any]?) -> Coordinator? {
        
        guard let appCoordinator = coordinator as? AppCoordinator else {
            return nil
        }
        
        let mainPageCoordinator = appCoordinator.runWorkerMainPageFlow()
        
        return mainPageCoordinator
    }
}
