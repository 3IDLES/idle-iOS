//
//  CenterAccountRegisterStage.swift
//  AuthFeature
//
//  Created by choijunios on 10/30/24.
//

import Foundation

enum CenterAccountRegisterStage: Int {
    
    case start
    case name
    case phoneNumber
    case businessOwner
    case idPassword
    case finish
    
    var screenKorName: String {
        switch self {
        case .start:
            "센터관리자 회원가입 시작"
        case .name:
            "이름 입력"
        case .phoneNumber:
            "전화번호 입력"
        case .businessOwner:
            "사업자 인증번호 입력"
        case .idPassword:
            "아이디 패스워드 입력"
        case .finish:
            "가입완료"
        }
    }
    
    var step: Int { self.rawValue }
}
