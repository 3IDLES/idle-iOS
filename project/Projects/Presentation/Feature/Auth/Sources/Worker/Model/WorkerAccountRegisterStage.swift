//
//  WorkerAccountRegisterStage.swift
//  AuthFeature
//
//  Created by choijunios on 10/30/24.
//

import Foundation

enum WorkerAccountRegisterStage: Int {
    
    case start
    case phoneNumber
    case info
    case address
    case finish
    
    var screenKorName: String {
        switch self {
        case .start:
            "요양보호사 회원가입 시작"
        case .phoneNumber:
            "전화번호 입력"
        case .info:
            "개인정보 입력"
        case .address:
            "거주지 입력"
        case .finish:
            "가입완료"
        }
    }
    
    var step: Int { self.rawValue }
}
