//
//  JWTError.swift
//  NetworkDataSource
//
//  Created by choijunios on 8/21/24.
//

import Foundation

enum JWTError: String, Error {
    case tokenDecodeException = "JWT-001"
    case tokenNotValid = "JWT-002"
    case tokenExpiredException = "JWT-003"
    case tokenNotFound = "JWT-004"
    case notSupportUserTokenType = "JWT-005"
    
    var message: String {
        switch self {
        case .tokenDecodeException:
            return "유효하지 않은 토큰, 토큰을 디코딩할 때, JWT의 형식에 맞지 않는 경우 발생합니다."
        case .tokenNotValid:
            return "유효하지 않은 토큰, 토큰 내 값 검증에 실패한 경우 발생합니다. (ex. 알고리즘, 서명)"
        case .tokenExpiredException:
            return "토큰이 만료된 경우 발생합니다. 재 로그인이 필요합니다."
        case .tokenNotFound:
            return "토큰을 찾을 수 없는 경우 발생합니다."
        case .notSupportUserTokenType:
            return "지원하지 않는 유저 토큰 타입을 사용한 경우 발생할 수 있습니다. (carer, center 제외)"
        }
    }
}
