//
//  CenterProfileRegisterCoordinatable.swift
//  PresentationCore
//
//  Created by choijunios on 7/27/24.
//

import Foundation
import Domain


public protocol CenterProfileRegisterCoordinatable: ParentCoordinator {
    
    func registerFinished()
    func showPreviewScreen(stateObject: CenterProfileRegisterState)
    func showCompleteScreen()
}
