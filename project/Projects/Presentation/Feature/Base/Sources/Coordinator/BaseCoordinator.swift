//
//  AppCoordinator.swift
//  RootFeature
//
//  Created by choijunios on 10/1/24.
//

import Foundation

/// 자식 코디네이터를 가질 수 있는 코디네이터
open class BaseCoordinator: Coordinator {
    
    public var onFinish: (() -> ())?
    
    var children: [Coordinator] = []
    
    public init(children: [Coordinator] = []) {
        self.children = children
    }
    
    open func start() { }
    
    public func addChild(_ coordinator: Coordinator) {
        
        children.append(coordinator)
    }
    
    public func removeChild(_ coordinator: Coordinator) {
        children.removeAll { $0 === coordinator}
    }
}

