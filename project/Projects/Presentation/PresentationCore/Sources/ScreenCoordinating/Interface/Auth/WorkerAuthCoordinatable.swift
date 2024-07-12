//
//  WorkerAuthCoordinatable.swift
//  PresentationCore
//
//  Created by choijunios on 7/1/24.
//

import Foundation

public protocol WorkerAuthCoordinatable: ParentCoordinator {
    
    func register()
    func authFinished()
}
