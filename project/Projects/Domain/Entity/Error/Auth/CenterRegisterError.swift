//
//  CenterRegisterError.swift
//  Entity
//
//  Created by choijunios on 7/8/24.
//

import Foundation

public enum CenterRegisterError: String, CustomError {
    
    case InvalidSmsVerificationNumber="SMS-001"
    case SmsVerificationNumberNotFound="SMS-002"
    case ClientException="SMS-003"
    
    // undefinedError
    case undefinedError="Err-000"
    
    public var message: String {
        switch self {
        case .InvalidSmsVerificationNumber:
            "전화번호 인증 시, 잘못된 인증번호를 입력한 경우 발생합니다."
        case .SmsVerificationNumberNotFound:
            "전화번호 인증 시, 인증번호가 만료되었거나 존재하지 않는 경우 발생합니다."
        case .ClientException:
            "SMS 문자 발송에 실패한 경우 발생합니다."
        case .undefinedError:
            "❌ 정의되지 않은 에러타입입니다. ❌"
        }
    }
}
