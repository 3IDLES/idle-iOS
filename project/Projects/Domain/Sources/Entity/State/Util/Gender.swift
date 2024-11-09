//
//  Gender.swift
//  Entity
//
//  Created by choijunios on 7/21/24.
//

import Foundation

public enum Gender: Int, Codable {
    case male
    case female
    case notDetermined
    
    public var twoLetterKoreanWord: String {
        switch self {
        case .notDetermined:
            "무결"
        case .male:
            "남성"
        case .female:
            "여성"
        }
    }
}
