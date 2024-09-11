//
//  CenterProfileRegisterCoordinatable.swift
//  PresentationCore
//
//  Created by choijunios on 7/27/24.
//

import Foundation
import Entity

public protocol CenterProfileRegisterCoordinatable: ParentCoordinator {
    
    func registerFinished()
    func showPreviewScreen(stateObject: CenterProfileRegisterState)
    func showCompleteScreen()
}
