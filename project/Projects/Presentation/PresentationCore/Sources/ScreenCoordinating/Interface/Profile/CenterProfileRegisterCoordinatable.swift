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
    func showCompleteScreen(cardVO: CenterProfileCardVO)
    func showMyCenterProfile()
}
