//
//  DeepLinkExecutable.swift
//  BaseFeature
//
//  Created by choijunios on 10/2/24.
//

import Foundation

public protocol DeepLinkTreeNode {
    
    var name: String { get }
    var children: [DeepLinkExecutable] { get }
    var isDestination: Bool { get set }
    
    func findChild(name: String) -> DeepLinkExecutable?
}

public protocol DeepLinkExecutable: DeepLinkTreeNode {
    @discardableResult
    func execute(with coordinator: Coordinator, userInfo: [String: String]?) -> Coordinator?
}

public extension DeepLinkExecutable {
    
    func findChild(name: String) -> DeepLinkExecutable? {
        children.first(where: { $0.name == name })
    }
}


