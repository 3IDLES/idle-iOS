//
//  DeregisterCoordinator.swift
//  RootFeature
//
//  Created by choijunios on 8/21/24.
//

import PresentationCore
import Entity

public protocol DeregisterCoordinator: ParentCoordinator {
    
    /// 센터관리자: 마지막으로 비밀번호를 입력합니다.
    func showFinalPasswordScreen(reasons: [DeregisterReasonVO])
    
    /// 요양보호사: 마지막으로 전화번호를 입력합니다.
    func showFinalPhoneAuthScreen(reasons: [DeregisterReasonVO])
}
