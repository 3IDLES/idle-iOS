//
//  PostApplicantDeepLink.swift
//  RootFeature
//
//  Created by choijunios on 10/9/24.
//

import Foundation
import CenterMainPageFeature
import BaseFeature

class PostApplicantDeepLink: DeepLinkExecutable {
    
    var name: String = "PostApplicantPage"
    
    var children: [DeepLinkExecutable] = []
    
    var isDestination: Bool = false
    
    init() { }
    
    func execute(with coordinator: Coordinator, userInfo: [String : String]?) -> Coordinator? {
        
        guard let centerMainPageCoordinator = coordinator as? CenterMainPageCoordinator else {
            return nil
        }
        
        guard let postId = userInfo?["postId"] else { return nil }
        
        centerMainPageCoordinator.presentPostApplicantPage(postId: postId)
        
        return centerMainPageCoordinator
    }
}
