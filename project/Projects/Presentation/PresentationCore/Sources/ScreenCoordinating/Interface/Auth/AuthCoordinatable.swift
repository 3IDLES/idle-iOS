//
//  AuthCoordinatable.swift
//  PresentationCore
//
//  Created by choijunios on 7/1/24.
//

import Foundation

public enum AuthType {
    
    case worker
    case center
}

public protocol AuthCoordinatable: ParentCoordinator {
    
    func authFinished()
    func showCompleteScreen()
    func registerAsWorker()
    func registerAsCenter()
    func startCenterLoginFlow()
}


