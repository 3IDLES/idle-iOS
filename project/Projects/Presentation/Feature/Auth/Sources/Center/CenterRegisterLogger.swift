//
//  CenterRegisterLogger.swift
//  AuthFeature
//
//  Created by choijunios on 9/18/24.
//

import Foundation

public protocol CenterRegisterLogger {
    
    /// 센터 회원가입의 각단계 집입시 로깅합니다.
    func logCenterRegisterStep(stepName: String, stepIndex: Int)
    
    /// 센터 회원가입의 시작시간을 기록합니다.
    func startCenterRegister()
    
    /// 센터 회원가입의 완료시간을 기록하고 걸린시간을 산출합니다.
    func logCenterRegisterDuration()
}

