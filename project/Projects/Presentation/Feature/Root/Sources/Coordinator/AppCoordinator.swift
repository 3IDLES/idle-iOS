//
//  AppCoordinator.swift
//  RootFeature
//
//  Created by choijunios on 10/1/24.
//

import Foundation


public protocol Coordinator2: AnyObject {
    
    /// Coordinator를 시작한다.
    func start()
}


/// 자식 코디네이터를 가질 수 있는 코디네이터
public class BaseCoordinator: Coordinator2 {
    
    var children: [Coordinator2] = []
    
    
    public init(children: [Coordinator2] = []) {
        self.children = children
    }
    
    open func start() { }
    
    public func addChild(_ coordinator: Coordinator2) {
        
        children.append(coordinator)
    }
    
    public func removeChild(_ coordinator: Coordinator2) {
        
        children.removeAll { $0 === coordinator}
    }
}

