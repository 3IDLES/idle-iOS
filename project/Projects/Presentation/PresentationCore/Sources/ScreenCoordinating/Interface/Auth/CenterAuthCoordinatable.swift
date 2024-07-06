//
//  CenterAuthCoordinatable.swift
//  PresentationCore
//
//  Created by choijunios on 7/1/24.
//

import Foundation

public protocol CenterAuthCoordinatable: ParentCoordinator {
    
    func login()
    func findPassword()
    func setNewPassword()
    func register()
    func authFinished()
}
