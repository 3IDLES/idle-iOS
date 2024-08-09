//
//  RecruitmentDeadline.swift
//  Entity
//
//  Created by choijunios on 7/31/24.
//

import Foundation

public enum ExperiencePreferenceType: Int, CaseIterable {
    case beginnerPossible
    case experiencedFirst
    
    public var korTextForBtn: String {
        switch self {
        case .beginnerPossible:
            "초보 가능"
        case .experiencedFirst:
            "경력 우대"
        }
    }
}

public enum ApplyType: Int, CaseIterable {
    case phoneCall
    case message
    case app
    
    public var korTextForBtn: String {
        switch self {
        case .phoneCall:
            "전화 지원"
        case .message:
            "문자 지원"
        case .app:
            "어플 지원"
        }
    }
    
    public var twoLetterKorTextForDisplay: String {
        switch self {
        case .phoneCall:
            "전화"
        case .message:
            "문자"
        case .app:
            "어플"
        }
    }
}

public enum ApplyDeadlineType: Int, CaseIterable {
    case untilApplicationFinished
    case specificDate
    
    public var korTextForBtn: String {
        switch self {
        case .untilApplicationFinished:
            "채용시 까지"
        case .specificDate:
            "마감일 설정"
        }
    }
}
