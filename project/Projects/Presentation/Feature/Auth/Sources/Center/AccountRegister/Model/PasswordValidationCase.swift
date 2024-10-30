//
//  PasswordValidationCase.swift
//  AuthFeature
//
//  Created by choijunios on 10/22/24.
//

import Foundation

enum PasswordValidationCase: Int, CaseIterable {
    case characterCount
    case alphabetAndNumberIncluded
    case noEmptySpace
    case unsuccessiveSame3words
    
    var indicatorText: String {
        
        switch self {
        case .characterCount:
            "8자~20자 사이"
        case .alphabetAndNumberIncluded:
            "영문자와 숫자 반드시 하나씩 포함"
        case .noEmptySpace:
            "공백 문자 사용 금지"
        case .unsuccessiveSame3words:
            "연속된 문자 3개 이상 사용 금지"
        }
    }
    
    static var items: [PasswordValidationCase] {
        PasswordValidationCase.allCases.sorted { $0.rawValue < $1.rawValue }
    }
}
