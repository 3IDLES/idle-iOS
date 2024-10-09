//
//  CenterMainPageDeepLink.swift
//  RootFeature
//
//  Created by choijunios on 10/9/24.
//

import Foundation
import BaseFeature

class CenterMainPageDeepLink: DeepLinkExecutable {
    
    var name: String = "CenterMainPage"
    
    var children: [DeepLinkExecutable] = [
        PostApplicantDeepLink()
    ]
    
    var isDestination: Bool = false
    
    init() { }
    
    func execute(with coordinator: Coordinator, userInfo: [String : String]?) -> Coordinator? {
        
        guard let appCoordinator = coordinator as? AppCoordinator else {
            return nil
        }
        
        let mainPageCoordinator = appCoordinator.runCenterMainPageFlow()
        
        return mainPageCoordinator
    }
}
