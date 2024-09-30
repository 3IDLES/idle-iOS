//
//  DeregisterReasonVO.swift
//  Entity
//
//  Created by choijunios on 8/21/24.
//

import Foundation

public enum DeregisterReasonVO: CaseIterable {
    case matchingIssues
    case inconvenienceUsingPlatform
    case noReasonToContinueUsing
    case usingOtherPlatform
    case lackOfDesiredFeatures
    case privacyConcerns
    case noLongerOperatingCenter
    
    public var reasonText: String {
        switch self {
        case .matchingIssues:
            return "매칭이 잘 이루어지지 않음"
        case .inconvenienceUsingPlatform:
            return "플랫폼 사용에 불편함을 느낌"
        case .noReasonToContinueUsing:
            return "플랫폼을 더 이상 사용할 이유가 없음"
        case .usingOtherPlatform:
            return "다른 플랫폼을 이용하고 있음"
        case .lackOfDesiredFeatures:
            return "원하는 기능의 부재"
        case .privacyConcerns:
            return "개인정보 보호 문제"
        case .noLongerOperatingCenter:
            return "더 이상 센터를 운영하지 않음"
        }
    }
}
