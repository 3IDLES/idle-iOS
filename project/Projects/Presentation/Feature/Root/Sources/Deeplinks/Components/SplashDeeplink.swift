//
//  SplashDeeplink.swift
//  RootFeature
//
//  Created by choijunios on 10/9/24.
//

import Foundation
import BaseFeature


class SplashDeeplink: DeeplinkExecutable {
    
    var name: String = "SplashPage"
    
    var children: [DeeplinkExecutable] = []
    
    var isDestination: Bool = false
    
    init() { }
    
    func execute(with coordinator: any BaseFeature.Coordinator, userInfo: [AnyHashable : Any]?) -> (any BaseFeature.Coordinator)? {
        guard let appCoordinator = coordinator as? AppCoordinator else {
            return nil
        }
        
        
        appCoordinator.runSplashFlow()
        
        
        return appCoordinator
    }
}
