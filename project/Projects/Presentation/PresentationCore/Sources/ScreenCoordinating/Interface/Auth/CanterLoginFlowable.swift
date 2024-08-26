//
//  CanterLoginFlowable.swift
//  PresentationCore
//
//  Created by choijunios on 8/27/24.
//

import Foundation

public protocol CanterLoginFlowable: ParentCoordinator {
    func login()
    func setNewPassword()
    func authFinished()
}
