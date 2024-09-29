//
//  WorkerRegisterLogger.swift
//  AuthFeature
//
//  Created by choijunios on 9/18/24.
//

import Foundation

public protocol WorkerRegisterLogger {
    
    /// 요양보호사 회원가입 각 화면 진입시 로깅
    func logWorkerRegisterStep(stepName: String, stepIndex: Int)
    
    /// 요양보호사 회원가입의 시작시간을 기록합니다.
    func startWorkerRegister()
    
    /// 요양보호사 회원가입의 완료시간을 기록하고 걸린시간을 산출합니다.
    func logWorkerRegisterDuration()
}

