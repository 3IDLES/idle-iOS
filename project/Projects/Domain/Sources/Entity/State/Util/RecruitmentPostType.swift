//
//  RecruitmentPostType.swift
//  Entity
//
//  Created by choijunios on 9/4/24.
//

import Foundation

public enum RecruitmentPostType: String, Codable {
    case native="CAREMEET"
    case workNet="WORKNET"
    
    public var upscaleEngWord: String {
        switch self {
        case .native:
            "CAREMEET"
        case .workNet:
            "WORKNET"
        }
    }
}

public struct RecruitmentPostInfo {
    public let type: RecruitmentPostType
    public let id: String
    
    public init(type: RecruitmentPostType, id: String) {
        self.type = type
        self.id = id
    }
}
