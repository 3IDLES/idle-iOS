//
//  DeepLinkExecutable.swift
//  BaseFeature
//
//  Created by choijunios on 10/2/24.
//

import Foundation

public protocol DeeplinkTreeNode {
    
    var name: String { get }
    var children: [DeeplinkExecutable] { get }
    var isDestination: Bool { get set }
    
    func findChild(name: String) -> DeeplinkExecutable?
}

public protocol DeeplinkExecutable: DeeplinkTreeNode {
    @discardableResult
    func execute(with coordinator: Coordinator, userInfo: [AnyHashable: Any]?) -> Coordinator?
}

public extension DeeplinkExecutable {
    
    func findChild(name: String) -> DeeplinkExecutable? {
        children.first(where: { $0.name == name })
    }
}


