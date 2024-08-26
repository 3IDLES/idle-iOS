//
//  CenterAuthCoordinatable.swift
//  PresentationCore
//
//  Created by choijunios on 7/1/24.
//

import Foundation

public protocol CanterLoginCoordinatable: ParentCoordinator {
    
    func login()
    func setNewPassword()
    func authFinished()
}
