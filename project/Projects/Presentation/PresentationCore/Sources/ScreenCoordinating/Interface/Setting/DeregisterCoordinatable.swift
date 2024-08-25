//
//  asd.swift
//  PresentationCore
//
//  Created by choijunios on 8/25/24.
//

import Foundation
import Entity

public protocol DeregisterCoordinatable: ParentCoordinator {
    
    /// 탈퇴과정이 끝났음을 알립니다.
    func flowFinished()
    
    /// 공통: 탈퇴 이유를 선택합니다.
    func showSelectReasonScreen()
    
    /// 센터관리자: 마지막으로 비밀번호를 입력합니다.
    func showFinalPasswordScreen(reasons: [DeregisterReasonVO])
    
    /// 요양보호사: 마지막으로 전화번호를 입력합니다.
    func showFinalPhoneAuthScreen(reasons: [DeregisterReasonVO])
    
    func coordinatorDidFinish()
}
