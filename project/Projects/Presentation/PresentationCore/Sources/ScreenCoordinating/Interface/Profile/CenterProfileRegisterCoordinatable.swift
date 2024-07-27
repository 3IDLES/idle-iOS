//
//  CenterProfileRegisterCoordinatable.swift
//  PresentationCore
//
//  Created by choijunios on 7/27/24.
//

import Foundation

public protocol CenterProfileRegisterCoordinatable: ParentCoordinator {
    
    func registerFinished()
    func showCompleteScreen()
    func showCenterProfile()
}
