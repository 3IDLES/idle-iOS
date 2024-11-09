//
//  PostApplicantDeeplink.swift
//  RootFeature
//
//  Created by choijunios on 10/9/24.
//

import Foundation
import CenterMainPageFeature
import BaseFeature

class PostApplicantDeeplink: DeeplinkExecutable {
    
    var component: DeepLinkPathComponent = .postApplicantPage
    
    var children: [DeeplinkExecutable] = []
    
    var isDestination: Bool = false
    
    init() { }
    
    func execute(with coordinator: any BaseFeature.Coordinator, userInfo: [AnyHashable : Any]?) -> Coordinator? {
    
        
        var targetCoordinator: CenterMainPageCoordinator
        
        if let centerMainCoordinator = coordinator as? CenterMainPageCoordinator {
            
            // 상위 Coordinator가 CenterMainPageCoordinator일 경우
            
            targetCoordinator = centerMainCoordinator
            
        } else if let appCoordinator = coordinator as? AppCoordinator, let centerMainCoordinator = appCoordinator.findChild(coordinatorType: CenterMainPageCoordinator.self) {
            
            // 상위 Coordinator가 AppCoordinator일 경우
            
            targetCoordinator = centerMainCoordinator
            
        } else {
            
            return nil
        }
        
        guard let postId = userInfo?["jobPostingId"] as? String else { return nil }
        
        targetCoordinator.presentPostApplicantPage(postId: postId)
        
        return targetCoordinator
    }
}
