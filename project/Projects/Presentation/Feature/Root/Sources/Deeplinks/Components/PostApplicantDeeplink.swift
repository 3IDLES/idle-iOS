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
    
    var name: String = "PostApplicantPage"
    
    var children: [DeeplinkExecutable] = []
    
    var isDestination: Bool = false
    
    init() { }
    
    func execute(with coordinator: any BaseFeature.Coordinator, userInfo: [AnyHashable : Any]?) -> Coordinator? {
        
        guard let centerMainPageCoordinator = coordinator as? CenterMainPageCoordinator else {
            return nil
        }
        
        guard let postId = userInfo?["postId"] as? String else { return nil }
        
        centerMainPageCoordinator.presentPostApplicantPage(postId: postId)
        
        return centerMainPageCoordinator
    }
}
