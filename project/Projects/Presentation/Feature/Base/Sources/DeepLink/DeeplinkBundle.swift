//
//  DeeplinkBundle.swift
//  BaseFeature
//
//  Created by choijunios on 10/17/24.
//

import Foundation

public struct DeeplinkBundle {
    public let deeplinks: [DeeplinkExecutable]
    public let userInfo: [AnyHashable: Any]?
    
    public init(deeplinks: [DeeplinkExecutable], userInfo: [AnyHashable : Any]?) {
        self.deeplinks = deeplinks
        self.userInfo = userInfo
    }
}
