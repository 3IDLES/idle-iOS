//
//  InputValidationError.swift
//  Entity
//
//  Created by choijunios on 7/10/24.
//

import Foundation

public enum InputValidationError: String, CustomError {
    
    case InvalidSmsVerificationNumber="SMS-001"
    case SmsVerificationNumberNotFound="SMS-002"
    case ClientException="SMS-003"
    
    case ExternalApiException="CLIENT-001"
    case CompanyNotFoundException="CLIENT-002"
    
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
        case .ExternalApiException:
            "외부 API에서 알 수 없는 문제가 발생한 경우를 모두 포함합니다."
        case .CompanyNotFoundException:
            "사업자 등록번호의 조회 결과가 없는 경우 발생합니다."
        // MARK: undefinedError
        case .undefinedError:
            "❌ 정의되지 않은 에러타입입니다. ❌"
        }
    }
}
