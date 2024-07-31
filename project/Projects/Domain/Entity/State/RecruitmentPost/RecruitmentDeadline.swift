//
//  RecruitmentDeadline.swift
//  Entity
//
//  Created by choijunios on 7/31/24.
//

import Foundation

public enum PreferenceAboutExp: Int, CaseIterable {
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

public enum ApplicationMethod: Int, CaseIterable {
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
}

public enum RecruitmentDeadline: Int, CaseIterable {
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
