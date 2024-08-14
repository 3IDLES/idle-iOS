//
//  RegisterRecruitmentPostCoordinatable.swift
//  PresentationCore
//
//  Created by choijunios on 8/5/24.
//

import Foundation

public protocol RegisterRecruitmentPostCoordinatable: ParentCoordinator {
    
    func showOverViewScreen()
    func showEditPostScreen()
    func showRegisterCompleteScreen()
    func registerFinished()
}
