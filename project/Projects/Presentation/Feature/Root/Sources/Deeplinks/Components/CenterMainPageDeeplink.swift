//
//  CenterMainPageDeeplink.swift
//  RootFeature
//
//  Created by choijunios on 10/9/24.
//

import Foundation
import BaseFeature

class CenterMainPageDeeplink: DeeplinkExecutable {
    
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
        
        let mainPageCoordinator = appCoordinator.runCenterMainPageFlow()
        
        return mainPageCoordinator
    }
}
