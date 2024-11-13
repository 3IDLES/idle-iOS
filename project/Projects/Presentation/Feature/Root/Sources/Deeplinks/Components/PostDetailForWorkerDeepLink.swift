//
//  PostDetailForWorkerDeepLink.swift
//  Root
//
//  Created by choijunios on 11/13/24.
//

import Foundation
import WorkerMainPageFeature
import PostDetailForWorkerFeature
import BaseFeature
import Domain

class PostDetailForWorkerDeepLink: DeeplinkExecutable {
    
    var component: DeepLinkPathComponent = .postDetailForWorkerPage
    
    var children: [DeeplinkExecutable] = []
    
    var isDestination: Bool = false
    
    init() { }
    
    func execute(with coordinator: any BaseFeature.Coordinator, userInfo: [AnyHashable : Any]?) -> Coordinator? {
    
        
        guard let appCoordinator = coordinator as? AppCoordinator else {
            return nil
        }
        
        guard let postId = userInfo?["jobPostingId"] as? String else { return nil }
        
        let postDetailForWorkerCoordinator = appCoordinator.postDetailForWorkerFlow(postInfo: .init(type: .native, id: postId))
        
        return postDetailForWorkerCoordinator
    }
}
