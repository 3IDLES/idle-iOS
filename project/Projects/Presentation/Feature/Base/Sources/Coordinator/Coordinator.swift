//
//  Coordinator.swift
//  BaseFeature
//
//  Created by choijunios on 10/6/24.
//

import Foundation

public protocol Coordinator: AnyObject {
    
    var onFinish: (() -> ())? { get set }
    
    /// Coordinator를 시작한다.
    func start()
}
