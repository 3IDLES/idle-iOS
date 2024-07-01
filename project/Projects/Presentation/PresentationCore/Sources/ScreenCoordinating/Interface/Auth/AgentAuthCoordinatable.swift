//
//  AgentAuthCoordinatable.swift
//  PresentationCore
//
//  Created by choijunios on 7/1/24.
//

import Foundation

public protocol AgentAuthCoordinatable: ParentCoordinator {
    
    func register()
    func authFinished()
}
