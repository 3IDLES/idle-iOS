//
//  DeepLinkExecutable.swift
//  BaseFeature
//
//  Created by choijunios on 10/2/24.
//

import Foundation

public protocol DeeplinkTreeNode {
    
    var component: DeepLinkPathComponent { get }
    var children: [DeeplinkExecutable] { get }
    var isDestination: Bool { get set }
    
    func findChild(component: DeepLinkPathComponent) -> DeeplinkExecutable?
}

public protocol DeeplinkExecutable: DeeplinkTreeNode {
    @discardableResult
    func execute(with coordinator: Coordinator, userInfo: [AnyHashable: Any]?) -> Coordinator?
}

public extension DeeplinkExecutable {
    
    func findChild(component: DeepLinkPathComponent) -> DeeplinkExecutable? {
        children.first(where: { $0.component == component })
    }
}


