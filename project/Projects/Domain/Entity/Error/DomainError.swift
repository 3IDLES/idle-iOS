//
//  DomainError.swift
//  Entity
//
//  Created by choijunios on 8/25/24.
//

import Foundation

public enum DomainError: Error {
    
    // API
    case invalidParameter
    
    // SECURITY
    case unAuthorizedRequest
    case invalidLoginRequest
    case invalidPassword
    case unregisteredUser
    
    // System
    case internalServerError
    
    // JWT
    case tokenDecodeException
    /// 리프래쉬필요
    case tokenNotValid
    /// 재로그인 필요
    case tokenExpiredException
    case tokenNotFound
    case notSupportUserTokenType
    
    // User
    case invalidVerificationNumber
    case verificationNumberNotFound
    case imageUploadNotCompleted
    
    // Center
    case duplicateIdentifier
    case alreadyExistCenterManager
    case alreadyExistCenter
    case centerNotFoundException
    
    // Carer
    case alreadyExistCarer
    
    // Persistence
    case resourceNotFound
    
    // SMS
    case clientException
    
    // Business Registration
    case businessCodeNotFound
    
    // Geocoding
    case geoCodingFailure
    
    // undefinedError
    case undefinedCode
    case undefinedError
    
    public init(code: String) {
        switch code {
        case "API-001":
            self = .invalidParameter
            
        case "SECURITY-001":
            self = .unAuthorizedRequest
        case "SECURITY-002":
            self = .invalidLoginRequest
        case "SECURITY-003":
            self = .invalidPassword
        case "SECURITY-004":
            self = .unregisteredUser
            
        case "SYSTEM-001":
            self = .internalServerError
            
        case "JWT-001":
            self = .tokenDecodeException
        case "JWT-002":
            self = .tokenNotValid
        case "JWT-003":
            self = .tokenExpiredException
        case "JWT-004":
            self = .tokenNotFound
        case "JWT-005":
            self = .notSupportUserTokenType
            
        case "USER-001":
            self = .invalidVerificationNumber
        case "USER-002":
            self = .verificationNumberNotFound
        case "USER-003":
            self = .imageUploadNotCompleted
            
        case "CENTER-001":
            self = .duplicateIdentifier
        case "CENTER-002":
            self = .alreadyExistCenterManager
        case "CENTER-003":
            self = .alreadyExistCenter
        case "CENTER-004":
            self = .centerNotFoundException
            
        case "CARER-001":
            self = .alreadyExistCarer
            
        case "PERSISTENCE-001":
            self = .resourceNotFound
            
        case "SMS-001":
            self = .clientException
            
        case "BUSINESS-REGISTRATION-001":
            self = .businessCodeNotFound
            
        case "GeoCode-001":
            self = .geoCodingFailure
            
        default:
            self = .undefinedError
        }
    }
    
    // MARK: 오류 메세지
    public var message: String {
        switch self {
        case .invalidParameter:
            return "요청하신 API에서 잘못된 파라미터가 입력되었습니다. 입력값을 다시 확인해주세요."
            
        case .unAuthorizedRequest:
            return "접근 권한이 없습니다. 로그인이 필요한 API에 접근하려면 로그인을 먼저 해주세요."
            
        case .invalidLoginRequest:
            return "로그인 실패: 입력하신 ID 또는 비밀번호가 잘못되었습니다. 존재하지 않는 ID로 로그인 시도 시에도 발생할 수 있습니다."
            
        case .invalidPassword:
            return "비밀번호가 일치하지 않습니다. 정확한 비밀번호를 입력해주세요. (예: 회원 탈퇴 시 비밀번호 입력 단계에서 발생)"
            
        case .unregisteredUser:
            return "등록되지 않은 사용자입니다. 회원가입이 필요합니다."
            
        case .internalServerError:
            return "서버 내부에서 문제가 발생했습니다. 잠시 후 다시 시도해주세요."
            
        case .tokenDecodeException:
            return "토큰 해석에 실패했습니다. 토큰의 형식이 올바른지 확인해주세요."
            
        case .tokenNotValid:
            return "유효하지 않은 토큰입니다. 토큰의 값이 올바른지 다시 확인해주세요."
            
        case .tokenExpiredException:
            return "토큰이 만료되었습니다. 다시 로그인해주세요."
            
        case .tokenNotFound:
            return "토큰을 찾을 수 없습니다. 요청을 다시 확인해주세요."
            
        case .notSupportUserTokenType:
            return "지원되지 않는 사용자 토큰 유형입니다. 사용 가능한 토큰 유형을 확인해주세요."
            
        case .invalidVerificationNumber:
            return "잘못된 인증번호입니다. 다시 입력해주세요."
            
        case .verificationNumberNotFound:
            return "인증번호가 만료되었거나 존재하지 않습니다. 새로운 인증번호를 요청해주세요."
            
        case .imageUploadNotCompleted:
            return "이미지 업로드가 완료되지 않았습니다. 다시 시도해주세요."
            
        case .duplicateIdentifier:
            return "이미 사용 중인 센터 ID입니다. 다른 ID를 사용해주세요."
            
        case .alreadyExistCenterManager:
            return "해당 센터 관리자 계정이 이미 존재합니다."
            
        case .alreadyExistCenter:
            return "이미 등록된 센터입니다. 다른 정보를 입력해주세요."
            
        case .centerNotFoundException:
            return "해당 센터를 찾을 수 없습니다. 조회 조건을 확인해주세요."
            
        case .alreadyExistCarer:
            return "이미 가입된 요양 보호사 정보가 존재합니다. 다른 정보를 입력해주세요."
            
        case .resourceNotFound:
            return "요청하신 리소스를 찾을 수 없습니다. 요청이 올바른지 다시 확인해주세요."
            
        case .clientException:
            return "SMS 발송에 실패했습니다. 입력된 정보를 다시 확인하거나 나중에 다시 시도해주세요."
            
        case .businessCodeNotFound:
            return "사업자 등록번호를 찾을 수 없습니다. 정확한 정보를 입력했는지 확인해주세요."
            
        case .geoCodingFailure:
            return "입력된 주소로 지리 정보를 찾을 수 없습니다. 주소를 다시 확인해주세요."
            
        case .undefinedCode, .undefinedError:
            return "예기치 않은 오류가 발생했습니다. 잠시 후 다시 시도해주세요."
        }
    }
}
