//
//  PostRegisterLogger.swift
//  CenterFeature
//
//  Created by choijunios on 9/18/24.
//

import Foundation

public protocol PostRegisterLogger {
    
    /// 공고 등록의 각화면 진입시 로깅합니다.
    func logPostRegisterStep(stepName: String, stepIndex: Int)
    
    /// 센터 회원가입의 시작시간을 기록합니다.
    func startPostRegister()
    
    /// 센터 회원가입의 완료시간을 기록하고 걸린시간을 산출합니다.
    func logPostRegisterDuration()
}
